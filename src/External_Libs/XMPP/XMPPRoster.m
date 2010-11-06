#import "XMPPRoster.h"
#import "XMPP.h"

@implementation XMPPRoster

- (id)initWithStream:(XMPPStream *)aXmppStream
{
	if ((self = [super initWithStream: aXmppStream]))
	{
		wasRosterRequested = NO;
		wasRosterReceived = NO;
	}
	
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Roster Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addToRoster:(XMPPJID *)jid withName:(NSString *)optionalName
{
	if(jid) {
		XMPPJID *myJID = xmppStream.myJID;
		
		// Check not re-adding own jid
		if(![[myJID bare] isEqualToString: [jid bare]]) {
			// Build & send IQ roster push stanza
			NSXMLElement *itemElement = [NSXMLElement elementWithName: @"item"];
			[itemElement addAttributeWithName: @"jid" stringValue: [jid bare]];
			
			if(optionalName) {
				[itemElement addAttributeWithName: @"name" stringValue: optionalName];
			}
			
			NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
			[queryElement addChild: itemElement];
			
			NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
			[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
			[iqStanza addChild: queryElement];
			
			[xmppStream sendElement: iqStanza];
			
			// Build & send presence subscribe stanza
			NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
			[presenceStanza addAttributeWithName: @"to" stringValue: [jid bare]];
			[presenceStanza addAttributeWithName: @"type" stringValue: @"subscribe"];
			
			[xmppStream sendElement: presenceStanza];
		}
	}
}

- (void)removeFromRoster:(XMPPJID *)jid
{
	if(jid) {
		XMPPJID *myJID = xmppStream.myJID;
		
		// Check not removing own jid
		if(![[myJID bare] isEqualToString: [jid bare]]) {
			// Build & send IQ roster push stanza
			NSXMLElement *itemElement = [NSXMLElement elementWithName: @"item"];
			[itemElement addAttributeWithName: @"jid" stringValue: [jid bare]];
			[itemElement addAttributeWithName: @"subscription" stringValue: @"remove"];
			
			NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
			[queryElement addChild: itemElement];
			
			NSXMLElement *iqStanza = [NSXMLElement elementWithName:@"iq"];
			[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
			[iqStanza addChild: queryElement];
			
			[xmppStream sendElement: iqStanza];
		}
	}	
}

- (void)setRosterItemName:(NSString *)name forJid:(XMPPJID *)jid
{
	if(jid) {
		// Build & send IQ roster push stanza
		NSXMLElement *itemElement = [NSXMLElement elementWithName: @"item"];
		[itemElement addAttributeWithName: @"jid" stringValue: [jid bare]];
		[itemElement addAttributeWithName: @"name" stringValue: name];
		
		NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
		[queryElement addChild: itemElement];
		
		NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
		[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
		[iqStanza addChild: queryElement];
		
		[xmppStream sendElement: iqStanza];
	}
}

- (void)acceptPresenceRequest:(XMPPJID *)jid
{
	// Build & send presence response
	NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
	[presenceStanza addAttributeWithName: @"to" stringValue: [jid bare]];
	[presenceStanza addAttributeWithName: @"type" stringValue: @"subscribed"];
	
	[xmppStream sendElement:presenceStanza];
}

- (void)rejectPresenceRequest:(XMPPJID *)jid
{
	// Build & send presence response
	NSXMLElement *presenceStanza = [NSXMLElement elementWithName: @"presence"];
	[presenceStanza addAttributeWithName: @"to" stringValue: [jid bare]];
	[presenceStanza addAttributeWithName: @"type" stringValue: @"unsubscribed"];
	
	[xmppStream sendElement: presenceStanza];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Collection of Roster
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchRoster
{
	if (!wasRosterRequested && !wasRosterReceived && [xmppStream isConnected]) {
		// Build & send roster stanza
		NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
		
		NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
		[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
		[iqStanza addChild: queryElement];
		
		[xmppStream sendElement: iqStanza];
	
		wasRosterRequested = YES;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender
{
	wasRosterRequested = NO;
	wasRosterReceived = NO;
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	// Note: Some jabber servers send an iq element with an xmlns.
	// Because of the bug in Apple's NSXML (documented in our elementForName method),
	// it is important we specify the xmlns for the query.
	NSString *iqType = [[iq attributeForName: @"type"] stringValue];
	NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
	
	if (queryElement) {
		NSArray *itemElements = [queryElement elementsForName: @"item"];

		// Notify delegates of roster items
		[multicastDelegate xmppRoster: self didReceiveRoster: itemElements isPush: wasRosterReceived];
		
		if (!wasRosterReceived && [iqType isEqualToString: @"result"]) {
			wasRosterReceived = YES;
		}
		
		return YES;
	}
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	// Notify delegates of incoming presence
	[multicastDelegate xmppRoster: self didReceivePresence: presence];
}

@end
