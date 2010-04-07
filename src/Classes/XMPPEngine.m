//
//  XMPPEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPEngine.h"
#import "XMPPClient.h"
#import "XMPPJID.h"
#import "XMPPIQ.h"
#import "NSXMLElementAdditions.h"
#import "BuddyRequestDelegate.h"

NSString *features[] = {
	@"http://jabber.org/protocol/disco#info",
	@"http://jabber.org/protocol/geoloc",
	@"http://jabber.org/protocol/geoloc+notify",
	nil
};

@implementation XMPPEngine

// Basic constructor
- (XMPPEngine*) init {
	[super init];
	
	xmpp = [[XMPPClient alloc] init];
	
	[xmpp addDelegate: self];
	[xmpp setDomain: @"cirrus.buddycloud.com"];
	[xmpp setPort: 443];
	[xmpp setMyJID: [XMPPJID jidWithUser: @"iphone2"
										domain: @"buddycloud.com"
								resource: @"buddycloud/iphone"]];
	[xmpp setPassword: @"iphone"];
	[xmpp setPriority: 10];
	[xmpp setAllowsPlaintextAuth: NO];
	[xmpp setAutoPresence: NO];
	[xmpp connect];
	
	return self;
}

- (XMPPClient*) client {
	return xmpp;
}

- (void)xmppClientDidNotConnect: (XMPPClient*)sender
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

- (void)xmppClient: (XMPPClient*)sender
didNotAuthenticate: (NSXMLElement*)error
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

- (void)xmppClientDidDisconnect: (XMPPClient*)sender
{
	if (!wasAuthedBefore)
		return [self xmppClient: sender
		     didNotAuthenticate: nil];
}

- (void)xmppClientDidAuthenticate: (XMPPClient*)sender
{	
	NSXMLElement *pres, *caps;
	
	wasAuthedBefore = YES;
	
	pres = [NSXMLElement elementWithName: @"presence"];
	caps = [NSXMLElement elementWithName: @"c"
								   xmlns: @"http://jabber.org/protocol/caps"];
	[caps addAttributeWithName: @"node"
				   stringValue: @"http://buddycloud.com/iphone/caps"];
	[caps addAttributeWithName: @"ver"
				   stringValue: @"0.0.1-alpha"];
	[pres addChild: caps];
	[xmpp sendElement: pres];
}

- (void)xmppClient: (XMPPClient*)sender
      didReceiveIQ: (XMPPIQ*)iq
{
	NSString *type = [[iq attributeForName: @"type"] stringValue];
	
	if ([type isEqualToString: @"get"]) {
		/* Ping */
		if ([iq elementForName: @"query"
						 xmlns: @"urn:xmpp:ping"])
			return [self sendPingReplyTo: [iq from]
						   withElementID: [iq elementID]];
		
		/* Version */
		if ([iq elementForName: @"query"
						 xmlns: @"jabber:iq:version"])
			return [self sendVersionReplyTo: [iq from]
							  withElementID: [iq elementID]];
		
		/* Disco */
		if ([iq elementForName: @"query"
						 xmlns: @"http://jabber.org/protocol/disco"
			 @"#info"])
			return [self answerDisco: iq];
		
		/* If we're still here, we don't handle it */
		[self send501ForIQ: iq];
	} else if ([type isEqualToString: @"set"])
		[self send501ForIQ: iq];
	else if ([type isEqualToString: @"result"]) {
		/* Locationquery result */
		if ([iq elementForName: @"location"
						 xmlns: @"http://buddycloud.com/protocol/"
			 @"location"])
			return;
		
		/* If we're still here, we don't handle it */
		[self send501ForIQ: iq];
	} else
		NSLog(@"WARNING: Received an IQ with invalid type!");	
}

-	(void)xmppClient: (XMPPClient*)sender
didReceiveBuddyRequest: (XMPPJID*)jid
{
	NSString *msg = [NSString stringWithFormat:
					 @"The user %@ wants to follow you.\n"
					 @"Do you want to accept his/her request?", [jid bare]];
	BuddyRequestDelegate *delegate = [[BuddyRequestDelegate alloc]
									  initWithJID: jid];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Following request"
						  message: msg
						  delegate: delegate
						  cancelButtonTitle: nil
						  otherButtonTitles: @"Yes", @"No", nil];
	[alert show];
	[alert release];
}

- (void)send501ForIQ: (XMPPIQ*)iq
{
	NSXMLElement *error, *fni, *text;
	
	[iq removeAttributeForName: @"to"];
	[iq addAttributeWithName: @"to"
				 stringValue: [[iq attributeForName: @"from"] stringValue]];
	[iq removeAttributeForName: @"from"];
	[iq removeAttributeForName: @"type"];
	[iq addAttributeWithName: @"type"
				 stringValue: @"error"];
	
	error = [NSXMLElement elementWithName: @"error"];
	[error addAttributeWithName: @"code"
					stringValue: @"501"];
	[error addAttributeWithName: @"type"
					stringValue: @"cancel"];
	
	fni = [NSXMLElement elementWithName: @"feature-not-implemented"
								  xmlns: @"urn:ietf:params:xml:ns:"
		   @"xmpp-stanzas"];
	[error addChild: fni];
	
	text = [NSXMLElement elementWithName: @"text"
							 stringValue: @"The feature requested is not "
			@"implemented by the recipient "
			@"or server and therefore cannot "
			@"be processed."];
	[text setXmlns: @"urn:ietf:params:xml:ns:xmpp-stanzas"];
	[error addChild: text];
	
	[iq addChild: error];
	
	[xmpp sendElement: iq];
}

- (void)sendPingReplyTo: (XMPPJID*)jid
		  withElementID: (NSString*)elementId
{
	NSXMLElement *iq, *query;
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to"
				 stringValue: [jid full]];
	[iq addAttributeWithName: @"type"
				 stringValue: @"result"];
	if (elementId)
		[iq addAttributeWithName: @"id"
					 stringValue: elementId];
	
	query = [NSXMLElement elementWithName: @"query"
									xmlns: @"urn:xmpp:ping"];
	[iq addChild: query];
	
	[xmpp sendElement: iq];
}

- (void)sendVersionReplyTo: (XMPPJID*)jid
			 withElementID: (NSString*)elementId
{
	NSXMLElement *iq, *query;
	UIDevice *device = [UIDevice currentDevice];
	NSMutableString *os = [NSMutableString stringWithCapacity: 0];
	[os appendString: [device systemName]];
	[os appendString: @" "];
	[os appendString: [device systemVersion]];
	[os appendString: @" @ "];
	[os appendString: [device model]];
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to"
				 stringValue: [jid full]];
	[iq addAttributeWithName: @"type"
				 stringValue: @"result"];
	if (elementId)
		[iq addAttributeWithName: @"id"
					 stringValue: elementId];
	
	query = [NSXMLElement elementWithName: @"query"
									xmlns: @"jabber:iq:version"];
	[query addChild: [NSXMLElement elementWithName: @"name"
									   stringValue: @"Buddycloud for "
					  @"iPhone"]];
	[query addChild: [NSXMLElement elementWithName: @"version"
									   stringValue: @"0.0.1-alpha"]];
	[query addChild: [NSXMLElement elementWithName: @"os"
									   stringValue: os]];
	[iq addChild: query];
	
	[xmpp sendElement: iq];
}

- (void)answerDisco: (XMPPIQ*)iq
{
	NSXMLElement *query, *identity, *feature;
	NSString **featureName;
	
	[iq removeAttributeForName: @"to"];
	[iq addAttributeWithName: @"to"
				 stringValue: [[iq attributeForName: @"from"] stringValue]];
	[iq removeAttributeForName: @"from"];
	[iq removeAttributeForName: @"type"];
	[iq addAttributeWithName: @"type"
				 stringValue: @"result"];
	
	query = [iq elementForName: @"query"
						 xmlns: @"http://jabber.org/protocol/disco#info"];
	identity = [NSXMLElement elementWithName: @"identity"];
	[identity addAttributeWithName: @"category"
					   stringValue: @"client"];
	[identity addAttributeWithName: @"type"
					   stringValue: @"mobile"];
	[query addChild: identity];
	
	// TODO: Check node
	
	for (featureName = features; *featureName != nil; featureName++) {
		feature = [NSXMLElement elementWithName: @"feature"];
		[feature addAttributeWithName: @"var"
						  stringValue: *featureName];
		[query addChild: feature];
	}
	
	[xmpp sendElement: iq];
}

@end
