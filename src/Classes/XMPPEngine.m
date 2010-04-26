//
//  XMPPEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPEngine.h"
#import "XMPPPubsub.h"
#import "XMPPStream.h"
#import "XMPPUser.h"
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
@synthesize password;
@synthesize lastItemIdReceived;

// Basic constructor
- (XMPPEngine *) init {
	[super init];
	
	// Initialize the XMPPStream
	xmppStream = [[XMPPStream alloc] init];
	
	[xmppStream addDelegate: self];
	[xmppStream setHostName: @"jabber.buddycloud.com"];
	[xmppStream setHostPort: 5222];
	[xmppStream setMyJID: [XMPPJID jidWithString: @"iphone2@buddycloud.com/iPhone/bcloud"]];
	
	// Initialize XMPPPubsub
	xmppPubsub = [[XMPPPubsub alloc] initWithStream: xmppStream toServer: @"pubsub-bridge@broadcaster.buddycloud.com"];
	[xmppPubsub addDelegate: self];
	
	return self;
}

- (void)connect
{	
	if (![xmppStream isConnected]) {
		isConnectionCold = YES;
		
		lastItemIdReceived = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastItemIdReceived"];
		
		// Connect to server
		NSError* error = nil;
		
		if (![xmppStream connect:&error]) {
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
	// TODO: Fetch roster
	//[xmppRoster fetchRoster];
	
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

- (void)xmppClientDidUpdateRoster:(XMPPClient *)sender
{
	// Roster has been updated
	if (!isPubsubAddedToRoster) {
		// Interate roster checking for pubsub server
		NSArray *roster = [xmppClient unsortedUsers];
		
		isPubsubAddedToRoster = YES;
		
		for (int i = 0; i < [roster count]; i++) {
			XMPPUser *user = [roster objectAtIndex: i];
			
			if ([[[user jid] bare] isEqualToString: [xmppPubsub serverName]]) {
				// Pubsub server is in roster
				// Collect users node subscriptions
				[xmppPubsub fetchOwnSubscriptions];
				
				return;
			}
		}
		
		// Pubsub server not found in roster
		[xmppClient addBuddy: [XMPPJID jidWithString: [xmppPubsub serverName]] withNickname: @"Buddycloud Service"];
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

- (void)xmppClient:(XMPPClient *)sender didReceiveBuddyRequest:(XMPPJID *)jid
{
	if ([[jid bare] isEqualToString: [xmppPubsub serverName]]) {
		// Accept pubsub server
		[xmppClient acceptBuddyRequest: jid];		
		
		// Collect users node subscriptions
		[xmppPubsub fetchOwnSubscriptions];
	}
	else {
		// Display following request
		NSString *msg = [NSString stringWithFormat:
						 @"The user %@ wants to follow you.\n"
						 @"Do you want to accept his/her request?", [jid bare]];
		
		BuddyRequestDelegate *delegate = [[BuddyRequestDelegate alloc] initWithJID: jid];
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Following request"
							  message: msg
							  delegate: delegate
							  cancelButtonTitle: nil
							  otherButtonTitles: @"Yes", @"No", nil];
		[alert show];
		[alert release];
	}	
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

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSMutableArray *)subscriptions
{
	// Handle users subscribed nodes
	isConnectionCold = NO;
	
	// Create followed item objects
	NSMutableArray *followingList = [[NSMutableArray alloc] init];
	for (NSXMLElement *elem in subscriptions) {
		NSString *node = [[elem attributeForName:@"node"] stringValue];
		NSArray *bits = [node componentsSeparatedByString:@"/"];
		if ([node hasPrefix:@"/user/"] && [node hasSuffix:@"/channel"]) {
			UserItem *item = [[UserItem alloc] init];
			item.ident = [bits objectAtIndex:2];
			item.channel = [[ChannelItem alloc] init];
			item.channel.affiliation = [ChannelItem affiliationFromString:[[elem attributeForName:@"affiliation"] stringValue]];
			item.channel.subscription = [ChannelItem subscriptionFromString:[[elem attributeForName:@"subscription"] stringValue]];
			[followingList addObject:item];
		}
		else if ([node hasPrefix:@"/channel/"]) {
			ChannelItem *item = [[ChannelItem alloc] init];
			item.ident = [bits objectAtIndex:2];
			item.affiliation = [ChannelItem affiliationFromString:[[elem attributeForName:@"affiliation"] stringValue]];
			item.subscription = [ChannelItem subscriptionFromString:[[elem attributeForName:@"subscription"] stringValue]];
			[followingList addObject:item];
		}
	}
	if ([followingList count] > 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:[Events INITIAL_SUBSCRIPTIONS] object:followingList];
	}
	
	// Send initial pubsub presence
	[self sendPresenceToPubsubWithLastItemId: lastItemIdReceived];
	
	// WA: Reset pubsub presence (google)
	if (lastItemIdReceived > 0) {
		[self sendPresenceToPubsubWithLastItemId: -1];
	}
	
	// Collect affiliations for the users node
	[xmppPubsub fetchAffiliationsForNode: [NSString stringWithFormat: @"/user/%@/channel", [[xmppClient myJID] bare]]];
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveAffiliations:(NSMutableArray *)affiliations forNode:(NSString *)node
{
	// Handle affiliations of users channel
	NSString *ownChannelNode = [NSString stringWithFormat: @"/user/%@/channel", [[xmppClient myJID] bare]];
	
	if ([node isEqualToString: ownChannelNode]) {
		NSArray *roster = [xmppClient unsortedUsers];
		
		// Iterate through roster
		for (int i = 0; i < [roster count]; i++) {
			XMPPUser *user = [roster objectAtIndex: i];
			NSString *userJid = [[user jid] bare];
			
			if (![userJid isEqualToString: [xmppPubsub serverName]]) {
				bool isAffiliated = NO;
				
				// Iterate through affiliations
				for (int x = 0; x < [affiliations count]; x++) {
					NSXMLElement *affiliation = [affiliations objectAtIndex: x];
					
					if ([[[affiliation attributeForName: @"jid"] stringValue] isEqualToString: userJid]) {
						// User in roster found in affiliations
						isAffiliated = YES;
						
						break;
					}
				}
				
				if (!isAffiliated) {
					// User not affiliated
					[xmppPubsub setAffiliationForUser: userJid onNode: ownChannelNode toAffiliation: @"publisher"];
				}
			}
		}
	}
}

@end
