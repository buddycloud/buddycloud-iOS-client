#import <Foundation/Foundation.h>
#import "XMPPModule.h"
#import "DDXML.h"

@class XMPPJID;
@class XMPPPresence;
@protocol XMPPRosterDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPRoster Definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPRoster : XMPPModule {
	BOOL wasRosterRequested;
	BOOL wasRosterReceived;
}

- (id)initWithStream:(XMPPStream *)xmppStream;

- (void)fetchRoster;

- (void)addToRoster:(XMPPJID *)jid withName:(NSString *)optionalName;
- (void)removeFromRoster:(XMPPJID *)jid;

- (void)setRosterItemName:(NSString *)name forJid:(XMPPJID *)jid;

- (void)acceptPresenceRequest:(XMPPJID *)jid;
- (void)rejectPresenceRequest:(XMPPJID *)jid;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoster Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPRosterDelegate
@optional

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRoster:(NSArray *)itemElements isPush:(BOOL)push;
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresence:(XMPPPresence *)presence;

@end
