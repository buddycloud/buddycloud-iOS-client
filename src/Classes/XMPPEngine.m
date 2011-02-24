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
#import "Geolocation.h"
#import "PostItem.h"
#import "DirectoryItem.h"
#import "Events.h"

NSString *discoFeatures[] = {
	@"http://jabber.org/protocol/pubsub",
	@"http://jabber.org/protocol/geoloc",
	nil
};

@implementation XMPPEngine
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize password;
@synthesize isNewUserRegisteration;
@synthesize authenticateAnonymously;
@synthesize lastItemIdReceived;

// Basic constructor
- (XMPPEngine *) init {
	if (self = [super init]) {;
		// Initialize the XMPPStream
		xmppStream = [[XMPPStream alloc] init];	
		xmppReconnect = [[XMPPReconnect alloc] init];
		
		[xmppStream addDelegate: self];
		[xmppStream setHostName: XMPP_ENGINE_SERVER];
		[xmppStream setHostPort: XMPP_ENGINE_SERVER_PORT];
		[xmppStream setMyJID: [XMPPJID jidWithUser:XMPP_ANONYMOUS_DEFAULT_JID domain:XMPP_BC_DOMAIN resource:XMPP_BC_IPHONE_RESOURCE]];
		[xmppReconnect setAutoReconnect:YES];
		//[xmppReconnect setShouldReconnect:YES];
		
		// You may need to alter these settings depending on the server you're connecting to
		allowSelfSignedCertificates = YES;
		allowSSLHostNameMismatch = YES;
		
		// Initialize XMPPRoster
		xmppRoster = [[XMPPRoster alloc] initWithStream: xmppStream];
		[xmppRoster addDelegate: self];
		
		// Initialize XMPPPubsub
		xmppPubsub = [[XMPPPubsub alloc] initWithStream: xmppStream toServer: XMPP_PUBSUB_SERVER];
		[xmppPubsub addDelegate: self];
		
		// Set notification observers
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onBroadLocationChanged:)
													 name: [Events BROAD_LOCATION_CHANGED]
												   object: nil];
		
		//Intially assumed new user registration flag would be Off.
		isNewUserRegisteration = NO;
	}
	
	return self;
}

- (void) dealloc {
	[xmppStream removeDelegate: self];
	[xmppReconnect removeDelegate: self];
	[xmppRoster removeDelegate: self];
	[xmppPubsub removeDelegate: self];
	
	[xmppStream release];
	[xmppReconnect release];
	[xmppRoster release];	
	[xmppPubsub release];
	
	[super dealloc];
}

- (void)connect
{	
	if (![xmppStream isConnected] && [[BuddycloudAppDelegate sharedAppDelegate] isConnectionAvailable]) {
		isConnectionCold = YES;
		
		// Load XMPPEngine settings
		if ((lastItemIdReceived = [[[NSUserDefaults standardUserDefaults] stringForKey: @"lastItemIdReceived"] longLongValue]) == 0) {
			lastItemIdReceived = 1;
		}
		
		// Connect to server
		NSError* error = nil;
		
		if (![xmppStream connect: &error]) {
			NSLog(@"ERR [XMPPEngine connect] %@", error);

			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(authenticatonFailedError, @""), [[xmppStream myJID] bare]];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:[[xmppStream myJID] bare], password, errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];

			error = [NSError errorWithDomain:XMPPStreamErrorDomain code:kreg_userAuthenticationError userInfo:info];
			[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_LOGGED_IN_FAILED] object: error];
		}
	}
	else {
		[CustomAlert showAlertMessageWithTitle:NSLocalizedString(alertPrompt, @"") showPreMsg:NSLocalizedString(noInternetConnError, @"")];
	}
}

- (void)disconnect
{
	if ([xmppStream isConnected]) {
		// Disconnect from server
		isConnectionCold = YES;
		
		//Rest the values.
		isNewUserRegisteration = NO; 
		authenticateAnonymously = NO;	
		
		[[NSUserDefaults standardUserDefaults] setObject: [NSString stringWithFormat: @"%qi", lastItemIdReceived] forKey: @"lastItemIdReceived"];
		
		[xmppStream disconnect];
	}
}

- (void)onBroadLocationChanged:(NSNotification *)notification
{
	// Store users new broad location
	[usersBroadLocation release];
	usersBroadLocation = [(NSString *)[notification object] retain];
	
	// Resend presence to XMPP server
	[self sendPresence];
}

- (BOOL)postChannelText:(NSString *)text toNode:(NSString *)node
{
	return [self postChannelText: text toNode: node inReplyTo: 0];
}

- (BOOL)postChannelText:(NSString *)text toNode:(NSString *)node inReplyTo:(long long)entryId
{
	NSXMLElement *contentElement = [NSXMLElement elementWithName: @"content" stringValue: text];
	[contentElement addAttributeWithName: @"type" stringValue: @"text"];

	NSXMLElement *entryElement = [NSXMLElement elementWithName: @"entry" xmlns: @"http://www.w3.org/2005/Atom"];
	[entryElement addAttributeWithName: @"xmlns:thr" stringValue: @"http://purl.org/syndication/thread/1.0"];
	[entryElement addChild: contentElement];
	
	if (entryId > 0) {
		// Set in-reply-to element
		NSXMLElement *inReplyToElement = [NSXMLElement elementWithName: @"thr:in-reply-to"];
		[inReplyToElement addAttributeWithName: @"ref" stringValue: [NSString stringWithFormat: @"%qi", entryId]];
		
		[entryElement addChild: inReplyToElement];
	}
	
	if ([usersBroadLocation length] > 0) {
		// Set geoloc element
		NSXMLElement *geolocElement = [NSXMLElement elementWithName: @"geoloc" xmlns: @"http://jabber.org/protocol/geoloc"];
		[geolocElement addChild: [NSXMLElement elementWithName: @"text" stringValue: usersBroadLocation]];
		
		[entryElement addChild: geolocElement];
	}
	
	NSXMLElement *itemElement = [NSXMLElement elementWithName: @"item"];
	[itemElement addChild: entryElement];
	
	[xmppPubsub publishItemToNode: node withItem: itemElement];
	
	return YES;
}

- (void)sendPresence
{
	// Build & send presence to XMPP server
	NSXMLElement *capsElement = [NSXMLElement elementWithName: @"c" xmlns: @"http://jabber.org/protocol/caps"];
	[capsElement addAttributeWithName: @"node" stringValue: @"http://buddycloud.com/caps"];
	[capsElement addAttributeWithName: @"ver" stringValue: applicationVersion];
	
	NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
	[presenceStanza addChild: capsElement];
	
	if ([usersBroadLocation length] > 0) {
		[presenceStanza addChild: [NSXMLElement elementWithName: @"status" stringValue: usersBroadLocation]];
	}
	
	[xmppStream sendElement: presenceStanza];	
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

- (void)followItem:(NSString *)item 
{
	if (item && [item length] > 0 && [item rangeOfString: @" "].location == NSNotFound) {
		NSString *lowercaseItem = [item lowercaseString];
		
		if ([lowercaseItem rangeOfString: @"@"].location != NSNotFound) {
			// Follow a user
			[xmppRoster addToRoster: [XMPPJID jidWithString: lowercaseItem] withName: nil];
 		}
		else {
			// Follow a channel
			NSString *node;
			
			if ([lowercaseItem rangeOfString: @"#"].location == 0) {
				node = [NSString stringWithFormat: @"/channel/%@", [lowercaseItem substringFromIndex: 1]];
			}
			else {
				node = [NSString stringWithFormat: @"/channel/%@", lowercaseItem];
			}
			
			[xmppPubsub subscribeToNode: node];
		}
	}
	else {
		CustomAlert *alert = [[CustomAlert alloc] initWithTitle: NSLocalizedString(@"Invalid ID", @"")
							  message: NSLocalizedString(@"Please enter a valid Jabber or #Channel ID", @"")
							  delegate: self
							  cancelButtonTitle: NSLocalizedString(@"Ok", @"")
							  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Directory & Directory Items
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getDirectories {
	@try {
		[self performSelector: @selector(getDirectoryItems:) withObject: nil];
	}
	@catch (NSException * e) {
		NSLog(@"Exception %@", [e description]);
	}
}

- (void)getDirectoryItems:(NSString *)sId 
{
	NSLog(@"--------------- getDirectoryEntries -------------");
	
	// Build directory item element
	NSXMLElement *directoryItemElement = [NSXMLElement elementWithName: @"items"];
	[directoryItemElement addAttributeWithName: @"var" stringValue: @"directory"];
	
	if (sId != nil) {
		[directoryItemElement addAttributeWithName: @"id" stringValue: sId];
	}
	
	// Build query result element
	NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"http://buddycloud.com/protocol/channels"];
	[queryElement addChild: directoryItemElement];

	// Build version IQ result
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"id" stringValue: @"channels1"];
	[iqStanza addAttributeWithName: @"to" stringValue: @"maitred.buddycloud.com"];
	[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
	[iqStanza addChild: queryElement];
	
	[xmppStream sendElement: iqStanza];
}

- (void)handleDirectoryItems:(XMPPIQ *)iq
{
	NSLog(@"--------------- handleDirectoryItems -------------");
	NSXMLElement *itemsElement = [[iq elementForName: @"query"] elementForName: @"items"];
	NSString *itemId = [[itemsElement attributeForName: @"id"] stringValue];
	NSMutableArray *itemsArray = [[NSMutableArray alloc] initWithCapacity: [[itemsElement elementsForName: @"item"] count]];

	if (!itemId) {
		//Directory List.
		for (NSXMLElement *item in [itemsElement elementsForName: @"item"]) {
			
			//NSLog(@"id : %@, title : %@", [[item elementForName: @"id"] stringValue], [[item elementForName: @"title"] stringValue]);
			
			DirectoryItem *directoryItem = [[DirectoryItem alloc] init];
			[directoryItem setDirectoryId: [[item elementForName: @"id"] stringValue]];
			[directoryItem setTitle: [[item elementForName: @"title"] stringValue]];
			[directoryItem setDescription: @"browse for interesting channels"];
			
			[itemsArray addObject:directoryItem];
			[directoryItem release];
		}

		// Notify observers
		[[NSNotificationCenter defaultCenter] postNotificationName: [Events DIRECTORY_LIST_UPDATED] object: [itemsArray retain]];
	}
	else {
		//Directory Items.
		NSMutableDictionary *directoryItem = [NSMutableDictionary dictionary];
		
		for (NSXMLElement *item in [itemsElement elementsForName: @"item"]) {
			ChannelItem *channelItem = [[ChannelItem alloc] init];
			[channelItem setIdent: [[item elementForName: @"id"] stringValue]];
			[channelItem setTitle: [[item elementForName: @"title"] stringValue]];
			[channelItem setDescription: [[item elementForName: @"description"] stringValue]];
			[channelItem setRank: [[[item elementForName: @"rank"] stringValue] intValue]];
			[channelItem setAffiliation: [ChannelItem affiliationFromString: @"none"]];
			[channelItem setSubscription: [ChannelItem subscriptionFromString: @"none"]];
			
			[itemsArray addObject:channelItem];
		}
		
		[directoryItem setObject:itemsArray forKey: itemId];
		
		// Notify observers
		[[NSNotificationCenter defaultCenter] postNotificationName: [Events DIRECTORY_ITEM_LIST_UPDATED] object: [directoryItem retain]];
		[directoryItem release];
	}
	
	//Release the items.
	[itemsArray release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel Metadata
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fetechMetadataForNode:(NSString *)node {
	
	[xmppPubsub fetchMetadataForNode: node];
	[xmppPubsub fetchAffiliationsForNode: node];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	NSLog(@"---------- xmppStream:willSecureWithSettings: ----------");
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidSecure: ----------");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidConnect: ----------");
	
	NSError *error = nil;
	
	if (authenticateAnonymously && !isNewUserRegisteration) {
		if (![xmppStream authenticateAnonymously: &error]) {	
			NSLog(@"Error authenticating: %@", error);
		}
	}
	else if (![xmppStream authenticateWithPassword: password error: &error]) {
		NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidNotConnect:(XMPPStream *)sender
{
	NSLog(@"---------- xmppStreamDidNotConnect: ----------");
	
	CustomAlert *alert = [[CustomAlert alloc]
						  initWithTitle: NSLocalizedString(@"Connection failed", @"")
						  message: NSLocalizedString(@"The client could not connect to the Buddycloud server", @"")
						  delegate: self
						  cancelButtonTitle: NSLocalizedString(@"Ok", @"")
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}



- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"---------- xmppStream:didNotAuthenticate: ----------");
	
	NSError * err = nil;
	
	//First check if it's not anonymous-bind user.
	if ([[[xmppStream myJID] bare] rangeOfString: XMPP_ANONYMOUS_DEFAULT_JID].location == NSNotFound) {

		//NOTE: Check if not authenticate because attempting to register for new account.
		if(isNewUserRegisteration) {
			if (![[self xmppStream] registerWithPassword:password error:&err]) {
				
				//Reset the state of 'isNewUserRegisteration'.
				isNewUserRegisteration = NO;
				[self disconnect];	//disconnect the last connection for registration process.
				
				NSXMLElement *errorElement = [error elementForName: @"error"];
				NSInteger errorCode = ([[errorElement attributeForName: @"code"] stringValue]) ? [[[errorElement attributeForName: @"code"] stringValue] integerValue] : kreg_unknwonError;
				
				NSString *errMsg = [NSString stringWithFormat: @"Registration Error = %d", errorCode];
				NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:[[xmppStream myJID] bare], password, errMsg, nil]  
																 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
				
				err = [NSError errorWithDomain:XMPPStreamErrorDomain code:errorCode userInfo:info];
				[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_REGISTRATION_FAILED] object: err];
			}
		}
		else {
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(authenticatonFailedError, @""), [[xmppStream myJID] bare]];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:[[xmppStream myJID] bare], password, errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];

			err = [NSError errorWithDomain:XMPPStreamErrorDomain code:kreg_userAuthenticationError userInfo:info];
			
			//User not able to logged-in coz of some error.
			[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_LOGGED_IN_FAILED] object: err];
		}
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{	
	NSLog(@"---------- xmppStream:xmppStreamDidAuthenticate: ----------");
	
	if (!isNewUserRegisteration) {
	
		//User successfully logged-in. Check if it's not anonymous-bind user.
		if ([[[xmppStream myJID] bare] rangeOfString: XMPP_ANONYMOUS_DEFAULT_JID].location == NSNotFound) {
			[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_LOGGED_IN_SUCCESS] object: sender];
		}
		
		// Fetch roster
		[xmppRoster fetchRoster];
		
		// Send presence
		[self sendPresence];
		
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
	else {
		
		NSLog(@"User Registration process >> user authenticate means already exist this account - conflict state!!");
		//Reset the state of 'isNewUserRegisteration', as registration process has been done.
		isNewUserRegisteration = NO;
		
		NSString *errMsg = NSLocalizedString(userNameConflictError, @"");
		NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:[[xmppStream myJID] bare], password, errMsg, nil]  
														 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
		
		NSError *err = [NSError errorWithDomain:XMPPStreamErrorDomain code:kreg_userNameConflictError userInfo:info];
		[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_REGISTRATION_FAILED] object: err];
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
	NSLog(@"---------- xmppStream:didReceiveError: ---------- : %@", [error description]);
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"---------- xmppStream:didReceiveIQ: ----------");
	
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
	else if ([iqType isEqualToString: @"result"]) {
		if ([iq elementForName: @"query" xmlns: @"http://buddycloud.com/protocol/channels"]) {
			//handle directcory items.
			[self handleDirectoryItems: iq];
			
			return YES;
		}
		
	}
	
	return NO;
}

- (void)sendPingResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId
{
	NSLog(@"---------- sendPingResultTo:withIQId: ----------");
	
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
	NSLog(@"---------- sendVersionResultTo:withIQId: ----------");
	
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
	NSLog(@"---------- sendFeatureDiscovery:withIQId: ----------");
	
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

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
	NSLog(@"---------- xmppStreamDidRegister ----------");
	
	//Reset the state of 'isNewUserRegisteration', as registration process has been done.
	if (isNewUserRegisteration) {
		isNewUserRegisteration = NO;
		[self disconnect];	//disconnect the last connection for registration process.
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_REGISTRATION_SUCCESS] object: sender];
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {

	NSLog(@"---------- xmppStream:didNotRegister: ----------");

	//Reset the state of 'isNewUserRegisteration', as registration process has been done.
	if (isNewUserRegisteration) {
		isNewUserRegisteration = NO;
		[self disconnect];	//disconnect the last connection for registration process.
	}
	
	NSXMLElement *errorElement = [error elementForName: @"error"];
	NSInteger errorCode = ([[errorElement attributeForName: @"code"] stringValue]) ? [[[errorElement attributeForName: @"code"] stringValue] integerValue] : kreg_unknwonError;
	
	NSString *errMsg = [NSString stringWithFormat: @"Registration Error = %d", errorCode];
	NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:[[xmppStream myJID] bare], password, errMsg, nil]  
													 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
	
	NSError *err = [NSError errorWithDomain:XMPPStreamErrorDomain code:errorCode userInfo:info];
	[[NSNotificationCenter defaultCenter] postNotificationName:[Events USER_REGISTRATION_FAILED] object: err];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoster Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRoster:(NSArray *)itemElements isPush:(BOOL)push
{
	NSLog(@"---------- xmppRoster:didReceiveRoster: ----------");
	
	NSString *ownChannelNode = [NSString stringWithFormat: @"/user/%@/channel", [[xmppStream myJID] bare]];
	NSMutableDictionary *oldFollowingData = [[NSMutableDictionary alloc] initWithDictionary: followingData];
	
	// Add own item if necessary
	if (!push) {
		UserItem *storedItem = [followingData objectForKey: ownChannelNode];
		
		if (!storedItem) {
			storedItem = [[UserItem alloc] init];
			[storedItem setIdent: [[xmppStream myJID] bare]];
			[storedItem setTitle: [[xmppStream myJID] bare]];
			[storedItem setSubscription: PRESSUB_BOTH];
			
			[followingData setObject: storedItem forKey: ownChannelNode];
		}
				
		[oldFollowingData removeObjectForKey: ownChannelNode];
	}
	
	// Iterate through received items
	for (NSXMLElement *item in itemElements) {
		NSString *itemJid = [[item attributeForName: @"jid"] stringValue];
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
	else if ([[presence type] isEqualToString: @"unsubscribed"]) {
		// Remove unsubscribed user from roster
		[xmppRoster removeFromRoster: [presence from]];
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
	NSMutableDictionary *subscribedItems = [[NSMutableDictionary alloc] initWithCapacity: [subscriptions count]];
	
	for (NSXMLElement *element in subscriptions) {
		ChannelItem *channelItem = [[ChannelItem alloc] init];
		[channelItem setAffiliation: [ChannelItem affiliationFromString: [[element attributeForName: @"affiliation"] stringValue]]];
		[channelItem setSubscription: [ChannelItem subscriptionFromString: [[element attributeForName: @"subscription"] stringValue]]];
		
		[subscribedItems setObject: channelItem forKey: [[element attributeForName: @"node"] stringValue]];
	}
	
	NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
	
	// Iterate followed items
	for (NSString *itemKey in followingData) {
		FollowedItem *followedItem = [followingData objectForKey: itemKey];
		ChannelItem *subscribedItem = [subscribedItems objectForKey: itemKey];
		
		if (subscribedItem) {
			// Item already in following list
			if ([followedItem isKindOfClass: [ChannelItem class]]) {
				// Is a topic channel
				if (subscribedItem) {
					// Update affiliation
					ChannelItem *channelItem = (ChannelItem *)followedItem;
					[channelItem setAffiliation: [subscribedItem affiliation]];
					[channelItem setSubscription: [subscribedItem subscription]];
				}
				else {
					// Add to remove list
					[keysToRemove addObject: itemKey];
				}
			}
			else if ([followedItem isKindOfClass: [UserItem class]]) {
				// Is a user channel
				UserItem *userItem = (UserItem *)followedItem;
				
				if (subscribedItem) {
					if (![userItem channel]) {
						// Set user channel
						[subscribedItem setIdent: itemKey];
						[userItem setChannel: subscribedItem];
					}
				}
				else if ([userItem channel]) {
					// Remove user channel
					[userItem setChannel: nil];
				}
			}
			
			// Remove from list
			[subscribedItems removeObjectForKey: itemKey];
		}
	}
	
	// Remove old followed items
	[followingData removeObjectsForKeys: keysToRemove];
	
	// Add newly followed topic channels
	for (NSString *node in subscribedItems) {
		if ([node hasPrefix: @"/channel/"]) {
			// Set topic channel
			ChannelItem *subscribedItem = [subscribedItems objectForKey: node];
			[subscribedItem setIdent: node];
			[subscribedItem setTitle: [NSString stringWithFormat: @"#%@", [node substringFromIndex: 9]]];
			
			[followingData setObject: subscribedItem forKey: node];
			
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
	//NSLog(@"Dict : %@ and Node: %@", metadata, node);
	FollowedItem *item = [followingData objectForKey: node];
	BOOL isFollowedItem = (item != nil && [item isKindOfClass: [ChannelItem class]]);	
	
	//Handle meta data.
	ChannelItem *channelItem = (isFollowedItem) ? (ChannelItem *)item : [[ChannelItem alloc] init];
	[channelItem setLastUpdated: [NSDate date]];
	[channelItem setTitle: [metadata objectForKey: @"pubsub#title"]];
	[channelItem setDescription: [metadata objectForKey: @"pubsub#description"]];
	[channelItem setRank: [[metadata objectForKey: @"x-buddycloud#rank"] intValue]];
	
	//Add further Info.
	ChannelDetailItem *channelDetailItem = [[[ChannelDetailItem alloc] initWithChannelItem: channelItem] autorelease];
	[channelDetailItem setOwner: [metadata objectForKey: @"pubsub#owner"]];
	[channelDetailItem setPopularity: [[metadata objectForKey: @"pubsub#popularity"] intValue]];
	[channelDetailItem setSubscribers: [[metadata objectForKey: @"pubsub#num_subscribers"] intValue]];
	[channelDetailItem.geoCordinateInfo setLatitude: [[metadata objectForKey: @"x-buddycloud#geoloc-lat"] longLongValue]];
	[channelDetailItem.geoCordinateInfo setLongitude: [[metadata objectForKey: @"x-buddycloud#geoloc-lon"] longLongValue]];
	[channelDetailItem.geoCordinateInfo setText: [metadata objectForKey: @"x-buddycloud#geoloc-text"]];
	 
	if (isFollowedItem) {
		// Is a topic channel - Notify observer.
		[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
	}
	 
	 //Notify observers for channel metadata.
	 [[NSNotificationCenter defaultCenter] postNotificationName: [Events CHANNEL_METADATA_ITEM_UPDATED] object: [channelDetailItem retain]]; 
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveChangedSubscription:(NSString *)subscription forNode:(NSString *)node
{
	// Handle subscription change for pubsub node
	FollowedItem *item = [followingData objectForKey: node];
	ChannelSubscription newSubscription = [ChannelItem subscriptionFromString: subscription];
	BOOL notifyObservers = NO;
	
	if (!item && [node hasPrefix: @"/channel/"] && newSubscription != CHANSUB_NONE) {
		// Add topic channel to list
		ChannelItem *channelItem = [[ChannelItem alloc] init];
		[channelItem setLastUpdated: [NSDate date]];
		[channelItem setIdent: node];
		[channelItem setTitle: [NSString stringWithFormat: @"#%@", [node substringFromIndex: 9]]];
		
		[followingData setObject: channelItem forKey: node];
		
		// Collect channel metadata
		[xmppPubsub fetchMetadataForNode: node];
		
		notifyObservers = YES;
		item = channelItem;
	}
	
	if (item) {
		ChannelItem *channelItem = [self getChannelItemForFollowedItem: item];
		
		if (!channelItem && [item isKindOfClass: [UserItem class]]) {
			// Set user channel
			channelItem = [[ChannelItem alloc] init];
			[channelItem setIdent: node];
			
			[(UserItem *)item setChannel: channelItem];
		}
		
		if (channelItem && [channelItem subscription] != newSubscription) {
			// Subscription did change
			[channelItem setSubscription: newSubscription];
			
			if ([channelItem subscription] == CHANSUB_SUBSCRIBED) {
				// Now subscribed to node, get items
				[xmppPubsub fetchItemsForNode: node];
				
				if ([item isKindOfClass: [UserItem class]]) {
					// Get mood & geoloc data for user
					[xmppPubsub fetchItemsForNode: [NSString stringWithFormat: @"/user/%@/mood", [item ident]]];
					[xmppPubsub fetchItemsForNode: [NSString stringWithFormat: @"/user/%@/geo/current", [item ident]]];
					[xmppPubsub fetchItemsForNode: [NSString stringWithFormat: @"/user/%@/geo/previous", [item ident]]];
					[xmppPubsub fetchItemsForNode: [NSString stringWithFormat: @"/user/%@/geo/future", [item ident]]];
				}
			}
			else if (newSubscription == CHANSUB_NONE) {
				// Unsubscribed to node
				if ([item isKindOfClass: [UserItem class]]) {
					// Remove channel from user item
					UserItem *userItem = (UserItem *)item;
					[userItem setChannel: nil];
				}
				else {
					// Remove topic channel from list
					[followingData removeObjectForKey: node];
				}

				notifyObservers = YES;
			}
		}
	}
	
	if (notifyObservers) {
		// Notify observers
		[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
	}
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveChangedAffiliation:(NSString *)affiliation forNode:(NSString *)node
{
	// Handle affiliation change for pubsub node
	FollowedItem *item = [followingData objectForKey: node];
	
	if (item) {
		ChannelItem *channelItem = [self getChannelItemForFollowedItem: item];
		ChannelAffiliation newAffiliation = [ChannelItem affiliationFromString: affiliation];
		
		if (channelItem && channelItem.affiliation != newAffiliation) {
			// Affiliation did change
			[channelItem setAffiliation: newAffiliation];
		}
	}
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveAffiliations:(NSArray *)affiliations forNode:(NSString *)node
{
	//NSLog(@"For node = %@ and affiliation count = %d", node, [affiliations count]);
	
	// Init & parse jid's from affiliation list
	NSMutableDictionary *affiliatedJids = [[NSMutableDictionary alloc] initWithCapacity: [affiliations count]];
	
	for (NSXMLElement *element in affiliations) {
		//NSLog(@"Jid = %@ and Affiliation = %@", [[element attributeForName: @"jid"] stringValue], [[element attributeForName: @"affiliation"] stringValue]);
		[affiliatedJids setObject: [[element attributeForName: @"affiliation"] stringValue] forKey: [[element attributeForName: @"jid"] stringValue]];
	}
	
	// Handle affiliations of users channel
	NSString *ownChannelNode = [NSString stringWithFormat: @"/user/%@/channel", [[xmppStream myJID] bare]];
	
	if ([node isEqualToString: ownChannelNode]) {

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
	else {
		//Notify observers for channel metadata - affilation request.
		[[NSNotificationCenter defaultCenter] postNotificationName: [Events CHANNEL_METADATA_ITEM_UPDATED] object: [affiliatedJids retain]]; 	
	}
	
	[affiliatedJids release];
}

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveItem:(NSXMLElement *)item forNode:(NSString *)node
{
	// Handle published item for node
	NSMutableString *itemKey = [NSMutableString stringWithString: node];
	
	if ([itemKey hasPrefix: @"/user/"] && ![itemKey hasSuffix: @"/channel"]) {
		NSRange clipRange = [itemKey rangeOfString: @"/" options: 0 range: NSMakeRange(6, [itemKey length] - 6)];
		clipRange.length = [itemKey length] - clipRange.location;
		
		[itemKey replaceCharactersInRange: clipRange withString: @"/channel"];
	}
	
	// Get followed item by key
	FollowedItem *followedItem = [followingData objectForKey: itemKey];
	
	if (followedItem) {
		NSXMLElement *publishedElement;
		BOOL notifyObservers = NO;
		
		if (publishedElement = [item elementForName: @"entry" xmlns: @"http://www.w3.org/2005/Atom"]) {
			// Published item is channel entry
			NSString *content = ([[publishedElement elementForName: @"content"] stringValue]) ? [[publishedElement elementForName: @"content"] stringValue] : @"";
			PostItem *post = [[[PostItem alloc] initWithChannelNode: node] autorelease];			
			[post setContent: content];
						
			if ([[post content] length] > 0) {
				// Only continue if the entry has some content
				NSXMLElement *authorElement = [publishedElement elementForName: @"author"];
				NSXMLElement *geolocElement = [publishedElement elementForName: @"geoloc" xmlns: @"http://jabber.org/protocol/geoloc"];
				
				if (authorElement) {
					// Set author data
					[post setAuthorName: [[authorElement elementForName: @"name"] stringValue]];
					[post setAuthorJid: [[authorElement elementForName: @"jid" xmlns: @"http://buddycloud.com/atom-elements-0"] stringValue]];
					[post setAuthorAffiliation: [ChannelItem affiliationFromString: [[authorElement elementForName: @"affiliation" xmlns: @"http://buddycloud.com/atom-elements-0"] stringValue]]];
				}
				
				// Set geoloc data
				[post setLocation: (geolocElement) ? [[geolocElement elementForName: @"text"] stringValue] : @""];
				[post setPostTimeFromString: (publishedElement) ? [[publishedElement elementForName: @"updated"] stringValue] : @""];
				
				// Set entry/comment data
				long long entryId = [[[item attributeForName: @"id"] stringValue] longLongValue];
				long long commentId = [[[[publishedElement elementForName: @"thr:in-reply-to"] attributeForName: @"ref"] stringValue] longLongValue];
				
				if (commentId == 0) {
					// Post is a new topic
					[post setEntryId: entryId];
				}
				else {
					// Post is a comment to a topic
					[post setEntryId: commentId];
					[post setCommentId: entryId];
				}
				
				// Insert post item
				if ([self insertPost: post] && ![post isRead]) {
					[followedItem setLastUpdated: [NSDate date]];
					
					notifyObservers = YES;
				}
			}
		}
		else if (publishedElement = [item elementForName: @"geoloc" xmlns: @"http://jabber.org/protocol/geoloc"]) {
			// Published item is geolocation
			if ([followedItem isKindOfClass: [UserItem class]]) {
				UserItem *userItem = (UserItem *)followedItem;
				GeoLocation *geoloc = [[[GeoLocation alloc] initFromXML: publishedElement] autorelease];
				
				if ([node hasSuffix: @"/geo/previous"] && ![[userItem geoPrevious] compare: geoloc]) {
					// Users previous geolocation is updated
					[userItem setGeoPrevious: geoloc];
					
					notifyObservers = YES;
				}
				else if ([node hasSuffix: @"/geo/current"] && ![[userItem geoCurrent] compare: geoloc]) {
					// Users current geolocation is updated
					[userItem setGeoCurrent: geoloc];
					[userItem setLastUpdated: [NSDate date]];
					
					if ([[userItem ident] isEqualToString: [[xmppStream myJID] bare]]) {
						// User's own location has changed
						[[NSNotificationCenter defaultCenter] postNotificationName: [Events GEOLOCATION_CHANGED] object: [userItem geoCurrent]];

						// Check future location
						if ([userItem geoFuture] && [[[userItem geoFuture] text] length] > 0 &&
							[[[userItem geoFuture] text] rangeOfString: [[userItem geoCurrent] text]].location == 0) {
						
							// Arrived at future location
							[[NSNotificationCenter defaultCenter] postNotificationName: [Events AT_FUTURE_GEOLOCATION] object: [userItem geoCurrent]];
						}
					}
					
					notifyObservers = YES;
				}
				else if ([node hasSuffix: @"/geo/future"] && ![[userItem geoFuture] compare: geoloc]) {
					// Users future geolocation is updated
					[userItem setGeoFuture: geoloc];
					
					if ([[[userItem geoFuture] text] length] > 0) {
						[userItem setLastUpdated: [NSDate date]];
					}
					
					notifyObservers = YES;
				}
			}
		}
		else if (publishedElement = [item elementForName: @"mood" xmlns: @"http://jabber.org/protocol/mood"]) {
			// Published item is mood
			NSString *moodText = [[publishedElement elementForName: @"text"] stringValue];
			
			if (![[followedItem description] isEqualToString: moodText]) {
				// Mood text changed
				[followedItem setDescription: moodText];
				[followedItem setLastUpdated: [NSDate date]];
				
				notifyObservers = YES;
			}
		}
		
		if (notifyObservers) {
			// Notify observers
			[[NSNotificationCenter defaultCenter] postNotificationName: [Events FOLLOWINGLIST_UPDATED] object: nil];
		}
	}
}

@end
