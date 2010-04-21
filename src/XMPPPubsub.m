//
//  XMPPPubsub.m
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPPubsub.h"
#import "XMPPClient.h"
#import "NSXMLElementAdditions.h"

typedef enum {
	kIqId_none = 0,
	kIqId_getOwnSubscriptions,
	kIqId_setAffiliation
} iqIdTypes;

@implementation XMPPPubsub
@synthesize serverName;

- (id)initWithXMPPClient:(XMPPClient *)client toServer:(NSString *)aServerName;
{
	if(self = [super init])
	{
		serverName = [aServerName retain];
	
		xmppClient = [client retain];
		[xmppClient addDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[serverName release];
	
	[xmppClient removeDelegate:self];
	[xmppClient release];
	
	[super dealloc];
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Service Discovery & User Node Retrieval
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchOwnSubscriptions 
{
	// Fetch the users own node subscriptions
	// http://xmpp.org/extensions/xep-0060.html#entity-subscriptions
	
	// Build & send subscriptions stanza
	NSXMLElement *pubsubElement = [NSXMLElement elementWithName: @"pubsub" xmlns: @"http://jabber.org/protocol/pubsub"];
	[pubsubElement addChild: [NSXMLElement elementWithName: @"subscriptions"]];
	
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"%d:%d", kIqId_getOwnSubscriptions, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Node Management Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"%d:%d", kIqId_setAffiliation, iqIdCounter++]];
	[iqStanza addChild: pubsubElement];
	
	[xmppClient sendElement: iqStanza];
}

@end
