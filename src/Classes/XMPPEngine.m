//
//  XMPPEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPEngine.h"
#import "XMPPStream.h"
#import "XMPPPubsub.h"
#import "XMPPRoster.h"
#import "XMPPJID.h"
#import "XMPPIQ.h"
#import "NSXMLElementAdditions.h"
#import "BuddyRequestDelegate.h"
#import "UserItem.h"
#import "ChannelItem.h"
#import "Events.h"

NSString *applicationVersion = @"iPhone-0.1.01";

NSString *discoFeatures[] = {
	@"http://jabber.org/protocol/pubsub",
	@"http://jabber.org/protocol/geoloc",
	nil
};

@implementation XMPPEngine
@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize password;
@synthesize lastItemIdReceived;

// Basic constructor
- (XMPPEngine *) init {
	if (self = [super init]) {;
		// Initialize the XMPPStream
		xmppStream = [[XMPPStream alloc] init];	
		[xmppStream addDelegate: self];
		[xmppStream setHostName: @"jabber.buddycloud.com"];
		[xmppStream setHostPort: 5222];
		[xmppStream setMyJID: [XMPPJID jidWithString: @"iphone2@buddycloud.com/iPhone/bcloud"]];
		
		// Initialize XMPPRoster
		xmppRoster = [[XMPPRoster alloc] initWithStream: xmppStream];
		[xmppRoster addDelegate: self];
		
		// Initialize XMPPPubsub
		xmppPubsub = [[XMPPPubsub alloc] initWithStream: xmppStream toServer: @"pubsub-bridge@broadcaster.buddycloud.com"];
		[xmppPubsub addDelegate: self];
	}
	
	return self;
}

- (void)connect
{	
	if (![xmppStream isConnected]) {
		isConnectionCold = YES;
		
		// Load XMPPEngine settings
		if ((lastItemIdReceived = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastItemIdReceived"]) == 0) {
			lastItemIdReceived = 1;
		}
		
		// Connect to server
		NSError* error = nil;
		
		if (![xmppStream connect: &error]) {
			NSLog(@"ERR [XMPPEngine connect] %@", error);
		}
	}
}

- (void)disconnect
{
	if ([xmppStream isConnected]) {
		// Disconnect from server
		isConnectionCold = YES;
		
		[[NSUserDefaults standardUserDefaults] setInteger: lastItemIdReceived forKey: @"lastItemIdReceived"];
		
		[xmppStream disconnect];
	}
}

- (void)sendPresenceToPubsubWithLastItemId:(int)itemId
{
	// Build & send presence to pubsub server
	NSXMLElement *pubsubPresenceStanza = [NSXMLElement elementWithName: @"presence"];
	[pubsubPresenceStanza addAttributeWithName: @"to" stringValue: [xmppPubsub serverName]];
	
	if (itemId > 0) {
		// Add RSM element if set
		NSXMLElement *setElement = [NSXMLElement elementWithName: @"set" xmlns: @"http://jabber.org/protocol/rsm"];
		[setElement addChild: [NSXMLElement elementWithName: @"after" stringValue: [NSString stringWithFormat: @"%d", itemId]]];
		
		[pubsubPresenceStanza addChild: setElement];
	}
	
	[xmppStream sendElement: pubsubPresenceStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidNotConnect:(XMPPStream *)sender
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Connection failed!"
						  message: @"The client could not connect to the "
						  @"Buddycloud server!"
						  delegate: self
						  cancelButtonTitle: @"OK"
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword: password error: &error]) {
		NSLog(@"Error authenticating: %@", error);
	}	
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Authentication failed!"
						  message: @"The client could not authenticate with the"
						  @"Buddycloud server!"
						  delegate: self
						  cancelButtonTitle: @"OK"
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{	
	// Fetch roster
	[xmppRoster fetchRoster];
	
	// Build & send presence with caps stanza
	NSXMLElement *capsElement = [NSXMLElement elementWithName: @"c" xmlns: @"http://jabber.org/protocol/caps"];
	[capsElement addAttributeWithName: @"node" stringValue: @"http://buddycloud.com/caps"];
	[capsElement addAttributeWithName: @"ver" stringValue: applicationVersion];
	
	NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
	[presenceStanza addChild: capsElement];
	
	[xmppStream sendElement: presenceStanza];
	
	if (isPubsubAddedToRoster) {
		// Collect users node subscriptions
		if (isConnectionCold) {
			[xmppPubsub fetchOwnSubscriptions];
		}
		else {
			// Send initial pubsub presence
			[self sendPresenceToPubsubWithLastItemId: lastItemIdReceived];
			
			// WA: Reset pubsub presence (google)
			if (lastItemIdReceived > 0) {
				[self sendPresenceToPubsubWithLastItemId: -1];
			}
		}
	}	
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *iqType = [[iq attributeForName: @"type"] stringValue];
	
	if ([iqType isEqualToString: @"get"]) {
		if ([iq elementForName: @"query" xmlns: @"urn:xmpp:ping"]) {
			// Handle ping
			[self sendPingResultTo: [iq from] withIQId: [iq elementID]];
			
			return YES;
		}
		else if ([iq elementForName: @"query" xmlns: @"jabber:iq:version"]) {
			// Handle client version request
			[self sendVersionResultTo: [iq from] withIQId: [iq elementID]];
			
			return YES;
		}
		else if ([iq elementForName: @"query" xmlns: @"http://jabber.org/protocol/disco#info"]) {
			// Handle feature discovery query
			[self sendFeatureDiscovery: iq];
			
			return YES;
		}
	}
	
	return NO;
}

- (void)sendPingResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId
{
	NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"urn:xmpp:ping"];

	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: [recipient full]];
	[iqStanza addAttributeWithName: @"type" stringValue: @"result"];
	
	if (iqId) {
		[iqStanza addAttributeWithName: @"id" stringValue: iqId];
	}
	
	[iqStanza addChild: queryElement];
	
	[xmppStream sendElement: iqStanza];
}

- (void)sendVersionResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId
{
	// Format current device description
	UIDevice *deviceInfo = [UIDevice currentDevice];
	NSMutableString *deviceDescription = [NSMutableString stringWithCapacity: 0];
	[deviceDescription appendString: [deviceInfo model]];
	[deviceDescription appendString: @" {"];
	[deviceDescription appendString: [deviceInfo systemName]];
	[deviceDescription appendString: @" "];
	[deviceDescription appendString: [deviceInfo systemVersion]];
	[deviceDescription appendString: @"}"];
	
	// Build query element
	NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:version"];
	[queryElement addChild: [NSXMLElement elementWithName: @"name" stringValue: @"Buddycloud"]];
	[queryElement addChild: [NSXMLElement elementWithName: @"version" stringValue: applicationVersion]];
	[queryElement addChild: [NSXMLElement elementWithName: @"os" stringValue: deviceDescription]];

	// Build feature discovery IQ result
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: [recipient full]];
	[iqStanza addAttributeWithName: @"type" stringValue: @"result"];
	
	if (iqId) {
		[iqStanza addAttributeWithName: @"id" stringValue: iqId];
	}
										   
	[iqStanza addChild: queryElement];
	
	[xmppStream sendElement: iqStanza];
}

- (void)sendFeatureDiscovery:(XMPPIQ *)iq
{
	// Build identity element
	NSXMLElement *identityElement = [NSXMLElement elementWithName: @"identity"];
	[identityElement addAttributeWithName: @"category" stringValue: @"client"];
	[identityElement addAttributeWithName: @"type" stringValue: @"mobile"];	
	
	// Build query result element
	NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"http://jabber.org/protocol/disco#info"];
	[queryElement addAttributeWithName: @"node" stringValue: [[[iq elementForName: @"query"] attributeForName: @"node"] stringValue]];
	[queryElement addChild: identityElement];
	
	// Build feature list
	NSString **featureName;
	
	for (featureName = discoFeatures; *featureName != nil; featureName++) {
		NSXMLElement *featureElement = [NSXMLElement elementWithName: @"feature"];
		[featureElement addAttributeWithName: @"var" stringValue: *featureName];		
		[queryElement addChild: featureElement];
	}
	
	// Build version IQ result
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: [[iq attributeForName:@"from"] stringValue]];
	[iqStanza addAttributeWithName: @"id" stringValue: [[iq attributeForName:@"id"] stringValue]];
	[iqStanza addAttributeWithName: @"type" stringValue: @"result"];
	[iqStanza addChild: queryElement];
	
	[xmppStream sendElement: iqStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoster Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRoster:(NSArray *)itemElements isPush:(BOOL)push
{
	NSString *ownChannelNode = [NSString stringWithFormat: @"/user/%@/channel", [[xmppStream myJID] bare]];
	NSMutableDictionary *oldFollowingData = [[NSMutableDictionary alloc] initWithDictionary: followingData];
	
	for (NSXMLElement *item in itemElements) {
		NSString *itemJid = [[item attributeForName: @"jid"] stringValue];
		NSString *itemName = [[item attributeForName: @"name"] stringValue];
		PresenceSubscription itemType = [UserItem subscriptionFromString: [[item attributeForName: @"subscription"] stringValue]];
		
		// Check for pubsub server jid
		if ([itemJid isEqualToString: [xmppPubsub serverName]]) {
			// Handle pubsub server item
			if(!isPubsubAddedToRoster && itemType == PRESSUB_BOTH) {
				isPubsubAddedToRoster = YES;
				
				[xmppPubsub fetchOwnSubscriptions];
			}
		}
		else {
			// Handle the non-pubsub item
			NSString *itemKey = [NSString stringWithFormat: @"/user/%@/channel", itemJid];
			UserItem *storedItem = [followingData objectForKey: itemKey];
			
			if (!storedItem && itemType > PRESSUB_NONE) {
				// Init & insert item
				storedItem = [[UserItem alloc] init];
				[storedItem setIdent: itemJid];
				[storedItem setTitle: itemJid];
				[storedItem setSubscription: PRESSUB_NONE];
				
				if ([itemName length] > 0) {
					[storedItem setTitle: itemName];
				}
					
				[followingData setObject: storedItem forKey: itemKey];
			}
			
			if (storedItem) {
				[oldFollowingData removeObjectForKey: itemKey];
				
				if (storedItem.subscription != itemType) {
					// Item subscription changed
					if (isPubsubAddedToRoster && push) {						
						if (storedItem.subscription < PRESSUB_FROM && itemType >= PRESSUB_FROM) {
							// Add user to own channel node subscribers
							[xmppPubsub setAffiliationForUser: itemJid onNode: ownChannelNode toAffiliation: @"publisher"];
						}
						else if (storedItem.subscription >= PRESSUB_FROM && itemType < PRESSUB_FROM) {
							// Remove user from own channel node subscribers
							[xmppPubsub setSubscriptionForUser: itemJid onNode: ownChannelNode toSubscription: @"none"];
						
							// TODO: Remove self from user's channel subscribers
						}
					}
					
					[storedItem setSubscription: itemType];
				}
				
				if (storedItem.subscription <= PRESSUB_NONE) {
					// Item has been removed
					[followingData removeObjectForKey: itemKey];
				}
			}			
		}
	}
	
	// Full roster has been collected
	if (!push) {
		// Iterate old following data, removing old followed users
		for (id key in oldFollowingData) {
			FollowedItem *item = [oldFollowingData objectForKey: key];
			
			if ([item isKindOfClass: [UserItem class]]) {
				UserItem *userItem = (UserItem *)item;
				
				if (isPubsubAddedToRoster && userItem.subscription >= PRESSUB_FROM) {
					// Remove user from own channel node subscribers
					[xmppPubsub setSubscriptionForUser: userItem.ident onNode: ownChannelNode toSubscription: @"none"];
					
					// TODO: Remove self from user's channel subscribers
				}

				// Remove user item from following data
				[followingData removeObjectForKey: key];
			}
		}
		
		if (!isPubsubAddedToRoster) {
			// Pubsub server not found in roster
			[xmppRoster addToRoster: [XMPPJID jidWithString: [xmppPubsub serverName]] withName: @"Buddycloud Service"];
		}
	}
		
	[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
}
								   
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresence:(XMPPPresence *)presence
{
	if ([[presence type] isEqualToString: @"subscribe"]) {
		if ([[[presence from] bare] isEqualToString: [xmppPubsub serverName]]) {
			// Accept pubsub server
			[xmppRoster acceptPresenceRequest: [presence from]];		
			
			// Collect users node subscriptions
			[xmppPubsub fetchOwnSubscriptions];
		}
		else {
			// TODO: Handle presence request (auto-subscribe for now)
			[xmppRoster acceptPresenceRequest: [presence from]];
			
			[xmppRoster addToRoster: [presence from] withName: nil];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubsub Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSArray *)subscriptions
{
	// Handle users subscribed nodes
	isConnectionCold = NO;
	
	// Init & parse subscriptions from list
	NSMutableDictionary *subscribedNodes = [[NSMutableDictionary alloc] initWithCapacity: [subscriptions count]];
	
	for (NSXMLElement *element in subscriptions) {
		[subscribedNodes setObject: [[element attributeForName: @"affiliation"] stringValue] forKey: [[element attributeForName: @"node"] stringValue]];
	}
	
	// Iterate followed items
	NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
	
	for (NSString *itemKey in followingData) {
		FollowedItem *item = [followingData objectForKey: itemKey];
		NSString *itemAffiliation = [subscribedNodes objectForKey: itemKey];
		
		if (itemAffiliation) {
			// Item already in following list
			if ([item isKindOfClass: [ChannelItem class]]) {
				// Is a topic channel
				if (itemAffiliation) {
					// Update affiliation
					ChannelItem *channelItem = (ChannelItem *)item;
					[channelItem setAffiliation: [ChannelItem affiliationFromString: itemAffiliation]];
				}
				else {
					// Add to remove list
					[keysToRemove addObject: itemKey];
				}
			}
			else if ([item isKindOfClass: [UserItem class]]) {
				// Is a user channel
				UserItem *userItem = (UserItem *)item;
				
				if (itemAffiliation) {
					if (!userItem.channel) {
						// Create user channel
						userItem.channel = [[ChannelItem alloc] init];
						[userItem.channel setIdent: itemKey];
						[userItem.channel setAffiliation: [ChannelItem affiliationFromString: itemAffiliation]];
					}
				}
				else if (userItem.channel) {
					// Remove user channel
					[userItem.channel dealloc];
					userItem.channel = nil;
				}
			}
			
			// Remove from list
			[subscribedNodes removeObjectForKey: itemKey];
		}
	}
	
	// Remove old followed items
	[followingData removeObjectsForKeys: keysToRemove];
	
	// Add newly followed topic channels
	for (NSString *node in subscribedNodes) {
		if ([node hasPrefix: @"/channel/"]) {
			// Create topic channel
			ChannelItem *channelItem = [[ChannelItem alloc] init];
			[channelItem setIdent: node];
			[channelItem setTitle: [NSString stringWithFormat: @"#%@", [node substringFromIndex: 9]]];
			[channelItem setAffiliation: [ChannelItem affiliationFromString: [subscribedNodes objectForKey: node]]];
			
			[followingData setObject: channelItem forKey: node];
			
			// Collect channel metadata
			[xmppPubsub fetchMetadataForNode: node];
		}
	}

	// Notify observers
	[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
	
	// Send initial pubsub presence
	[self sendPresenceToPubsubWithLastItemId: lastItemIdReceived];
	
	// WA: Reset pubsub presence (google)
	if (lastItemIdReceived > 0) {
		[self sendPresenceToPubsubWithLastItemId: -1];
	}
	
	// Collect affiliations for the users node
	[xmppPubsub fetchAffiliationsForNode: [NSString stringWithFormat: @"/user/%@/channel", [[xmppStream myJID] bare]]];
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveMetadata:(NSDictionary *)metadata forNode:(NSString *)node
{
	// Handle metadata for a pubsub node
	FollowedItem *item = [followingData objectForKey: node];
	
	if (item) {
		if ([item isKindOfClass: [ChannelItem class]]) {
			// Is a topic channel
			[item setLastUpdated: [NSDate date]];
			[item setTitle: [metadata objectForKey: @"pubsub#title"]];
			[item setDescription: [metadata objectForKey: @"pubsub#description"]];
			
			// Notify observers
			[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
		}
	}
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveAffiliations:(NSArray *)affiliations forNode:(NSString *)node
{
	// Handle affiliations of users channel
	NSString *ownChannelNode = [NSString stringWithFormat: @"/user/%@/channel", [[xmppStream myJID] bare]];
	
	if ([node isEqualToString: ownChannelNode]) {
		// Init & parse jid's from affiliation list
		NSMutableDictionary *affiliatedJids = [[NSMutableDictionary alloc] initWithCapacity: [affiliations count]];
		
		for (NSXMLElement *element in affiliations) {
			[affiliatedJids setObject: [[element attributeForName: @"affiliation"] stringValue] forKey: [[element attributeForName: @"jid"] stringValue]];
		}
		
		// Iterate roster items for affiliated users
		for (id itemKey in followingData) {
			FollowedItem *item = [followingData objectForKey: itemKey];
			
			if ([item isKindOfClass: [UserItem class]]) {
				NSString *userAffiliation = [affiliatedJids objectForKey: item.ident];
				
				if (userAffiliation) {
					// User is affiliated, remove from list
					[affiliatedJids removeObjectForKey: item.ident];
				}
				else {
					// Add user to own node affiliations
					[xmppPubsub setAffiliationForUser: item.ident onNode: ownChannelNode toAffiliation: @"publisher"];
				}
			}
		}
		
		// TODO: If whitelist config, remove remaining affiliators from own node
	}
}

@end
