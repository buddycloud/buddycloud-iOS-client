//
//  XMPPPubsub.m
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPPubsub.h"
#import "XMPPClient.h"
#import "XMPPJID.h"
#import "NSXMLElementAdditions.h"
#import "MulticastDelegate.h"

#define RSM_MAX 50

typedef enum {
	kIqId_none = 0,
	kIqId_getOwnSubscriptions,
	kIqId_getNodeAffiliations,
	kIqId_setSubscription,
	kIqId_setAffiliation
} iqIdTypes;

@implementation XMPPPubsub
@synthesize serverName;

- (id)initWithXMPPClient:(XMPPClient *)client toServer:(NSString *)aServerName;
{
	if(self = [super init])
	{
		multicastDelegate = [[MulticastDelegate alloc] init];
		
		serverName = [aServerName retain];
	
		xmppClient = [client retain];
		[xmppClient addDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[multicastDelegate release];
	
	[serverName release];
	
	[xmppClient removeDelegate:self];
	[xmppClient release];
	
	[super dealloc];
}

- (void)addDelegate:(id)delegate
{
	[multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

- (void)xmppClient:(XMPPClient *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *iqType = [[iq attributeForName:@"type"] stringValue];
	
	if([iqType isEqualToString:@"result"]) {
		// Process IQ result
		NSArray *iqIdData = [[[iq attributeForName:@"id"] stringValue] componentsSeparatedByString: @":"];
		
		if ([iqIdData count] >= 2 && [(NSString *) [iqIdData objectAtIndex: 0] isEqualToString: @"pub"]) {
			int iqIdType = [(NSString *) [iqIdData objectAtIndex: 1] intValue];
			
			if (iqIdType == kIqId_getOwnSubscriptions) {
				
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Service Discovery & User Node Retrieval
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchOwnSubscriptions
{
	// Fetch the users own node subscriptions
	// http://xmpp.org/extensions/xep-0060.html#entity-subscriptions
	
	[self fetchOwnSubscriptionsAfter: nil];
}

- (void)fetchOwnSubscriptionsAfter:(NSString *)node
{
	// Fetch the users own node subscriptions
	// http://xmpp.org/extensions/xep-0060.html#entity-subscriptions
	
	// Build & send subscriptions stanza
	NSXMLElement *pubsubElement = [NSXMLElement elementWithName: @"pubsub" xmlns: @"http://jabber.org/protocol/pubsub"];
	[pubsubElement addChild: [NSXMLElement elementWithName: @"subscriptions"]];
	
	NSXMLElement *setElement = [NSXMLElement elementWithName: @"set" xmlns: @"http://jabber.org/protocol/rsm"];
	[setElement addChild: [NSXMLElement elementWithName: @"max" stringValue: [NSString stringWithFormat: @"%d", RSM_MAX]]];
	
	if ([node length] > 0) {
		[setElement addChild: [NSXMLElement elementWithName: @"after" stringValue: node]];
	}
	
	[pubsubElement addChild: setElement];
	
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"pub:%d:%d", kIqId_getOwnSubscriptions, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Node Affiliation & Subscription Retrieval
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchAffiliationsForNode:(NSString *)node
{
	// Fetch the affiliation list of a node
	// http://xmpp.org/extensions/xep-0060.html#owner-affiliations-retrieve
	
	[self fetchAffiliationsForNode: node afterJid: nil];
}

- (void)fetchAffiliationsForNode:(NSString *)node afterJid:(NSString *)jid
{
	// Fetch the affiliation list of a node
	// http://xmpp.org/extensions/xep-0060.html#owner-affiliations-retrieve
	
	// Build & send affiliations stanza
	NSXMLElement *affiliationsElement = [NSXMLElement elementWithName: @"affiliations"];
	[affiliationsElement addAttributeWithName: @"node" stringValue: node];
	
	NSXMLElement *pubsubElement = [NSXMLElement elementWithName: @"pubsub" xmlns: @"http://jabber.org/protocol/pubsub#owner"];
	[pubsubElement addChild: affiliationsElement];
	
	NSXMLElement *setElement = [NSXMLElement elementWithName: @"set" xmlns: @"http://jabber.org/protocol/rsm"];
	[setElement addChild: [NSXMLElement elementWithName: @"max" stringValue: [NSString stringWithFormat: @"%d", RSM_MAX]]];
	
	if ([jid length] > 0) {
		[setElement addChild: [NSXMLElement elementWithName: @"after" stringValue: jid]];
	}
	
	[pubsubElement addChild: setElement];
	
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"pub:%d:%d", kIqId_getNodeAffiliations, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Node Management Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSubscriptionForUser:(NSString *)jid onNode:(NSString *)node toSubscription:(NSString *)subscription
{
	// Set a users subscription to a pubsub node
	// http://xmpp.org/extensions/xep-0060.html#owner-subscriptions-modify
	
	// Build & send subscription stanza
	NSXMLElement *subscriptionElement = [NSXMLElement elementWithName: @"subscription"];
	[subscriptionElement addAttributeWithName: @"jid" stringValue: jid];
	[subscriptionElement addAttributeWithName: @"subscription" stringValue: subscription];
	
	NSXMLElement *subscriptionsElement = [NSXMLElement elementWithName: @"subscriptions"];
	[subscriptionsElement addAttributeWithName: @"node" stringValue: node];
	[subscriptionsElement addChild: subscriptionElement];
	
	NSXMLElement *pubsubElement = [NSXMLElement elementWithName: @"pubsub" xmlns: @"http://jabber.org/protocol/pubsub#owner"];
	[pubsubElement addChild: subscriptionsElement];
	
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"pub:%d:%d", kIqId_setSubscription, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

- (void)setAffiliationForUser:(NSString *)jid onNode:(NSString *)node toAffiliation:(NSString *)affiliation
{
	// Set a users affiliation to a pubsub node
	// http://xmpp.org/extensions/xep-0060.html#owner-affiliations-modify
	
	// Build & send affiliation stanza
	NSXMLElement *affiliationElement = [NSXMLElement elementWithName: @"affiliation"];
	[affiliationElement addAttributeWithName: @"jid" stringValue: jid];
	[affiliationElement addAttributeWithName: @"affiliation" stringValue: affiliation];
	
	NSXMLElement *affiliationsElement = [NSXMLElement elementWithName: @"affiliations"];
	[affiliationsElement addAttributeWithName: @"node" stringValue: node];
	[affiliationsElement addChild: affiliationElement];
	
	NSXMLElement *pubsubElement = [NSXMLElement elementWithName: @"pubsub" xmlns: @"http://jabber.org/protocol/pubsub#owner"];
	[pubsubElement addChild: affiliationsElement];
	
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"pub:%d:%d", kIqId_setAffiliation, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

@end
