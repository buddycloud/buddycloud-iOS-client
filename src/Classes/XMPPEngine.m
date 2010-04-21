//
//  XMPPEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPEngine.h"
#import "XMPPClient.h"
#import "XMPPPubsub.h"
#import "XMPPJID.h"
#import "XMPPIQ.h"
#import "NSXMLElementAdditions.h"
#import "BuddyRequestDelegate.h"

NSString *applicationVersion = @"iPhone-0.1.01";

NSString *discoFeatures[] = {
	@"http://jabber.org/protocol/pubsub",
	@"http://jabber.org/protocol/geoloc",
	nil
};

@implementation XMPPEngine
@synthesize xmppClient;

// Basic constructor
- (XMPPEngine *) init {
	[super init];
	
	// Initialize the XMPPClient
	xmppClient = [[XMPPClient alloc] init];
	
	[xmppClient addDelegate: self];
	[xmppClient setDomain: @"jabber.buddycloud.com"];
	[xmppClient setPort: 5222];
	[xmppClient setMyJID: [XMPPJID jidWithUser: @"iphone2"
										domain: @"buddycloud.com"
								resource: @"iPhone/bcloud"]];
	[xmppClient setPassword: @"iphone"];
	[xmppClient setPriority: 10];
	[xmppClient setAllowsPlaintextAuth: NO];
	[xmppClient setAutoPresence: NO];
	
	// Initialize XMPPPubsub
	xmppPubsub = [[XMPPPubsub alloc] initWithXMPPClient:xmppClient delegate:self];
	[xmppPubsub setPubsubServer:@"broadcaster.buddycloud.com"];
	
	return self;
}

- (void)connect
{
	if (xmppClient && ![xmppClient isConnected]) {
		// Connect to server
		[xmppClient connect];
	}
}

- (void)xmppClientDidNotConnect:(XMPPClient *)sender
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

- (void)xmppClient:(XMPPClient *)sender didNotAuthenticate:(NSXMLElement *)error
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

- (void)xmppClientDidDisconnect:(XMPPClient *)sender
{
	if (!wasAuthedBefore) {
		return [self xmppClient: sender didNotAuthenticate: nil];
	}
}

- (void)xmppClientDidAuthenticate:(XMPPClient *)sender
{	
	wasAuthedBefore = YES;
	
	// Build presence with caps stanza
	NSXMLElement *capsElement = [NSXMLElement elementWithName: @"c" xmlns: @"http://jabber.org/protocol/caps"];
	[capsElement addAttributeWithName: @"node" stringValue: @"http://buddycloud.com/caps"];
	[capsElement addAttributeWithName: @"ver" stringValue: applicationVersion];
	
	NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
	[presenceStanza addChild: capsElement];
	
	// Send presence
	[xmppClient sendElement: presenceStanza];
}

- (void)xmppClient:(XMPPClient *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *type = [[iq attributeForName: @"type"] stringValue];
	
	if ([type isEqualToString: @"get"]) {
		if ([iq elementForName: @"query" xmlns: @"urn:xmpp:ping"]) {
			// Handle ping
			return [self sendPingResultTo: [iq from] withIQId: [iq elementID]];
		}
		else if ([iq elementForName: @"query" xmlns: @"jabber:iq:version"]) {
			// Handle client version request
			return [self sendVersionResultTo: [iq from] withIQId: [iq elementID]];
		}
		else if ([iq elementForName: @"query" xmlns: @"http://jabber.org/protocol/disco#info"]) {
			// Handle feature discovery query
			return [self sendFeatureDiscovery: iq];
		}
	}
}

- (void)xmppClient:(XMPPClient *)sender didReceiveBuddyRequest:(XMPPJID *)jid
{
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
	
	[xmppClient sendElement: iqStanza];
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
	
	[xmppClient sendElement: iqStanza];
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
	
	[xmppClient sendElement: iqStanza];
}

@end
