//
//  XMPPPubsub.h
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MulticastDelegate;
@class XMPPClient;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub : NSObject {
	MulticastDelegate *multicastDelegate;
	
	XMPPClient *xmppClient;
	
	NSString *serverName;
	
	int iqIdCounter;
}

@property(readonly) NSString *serverName;

- (id)initWithXMPPClient:(XMPPClient *)client toServer:(NSString *)serverName;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (void)fetchOwnSubscriptions;

- (void)fetchAffiliationsForNode:(NSString *)node;

- (void)setSubscriptionForUser:(NSString *)jid onNode:(NSString *)node toSubscription:(NSString *)subscription;
- (void)setAffiliationForUser:(NSString *)jid onNode:(NSString *)node toAffiliation:(NSString *)affiliation;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub (PrivateAPI)

- (void)fetchOwnSubscriptionsAfter:(NSString *)node;
- (void)fetchAffiliationsForNode:(NSString *)node afterJid:(NSString *)jid;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubsub Delegate definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (XMPPPubsubDelegate)

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSMutableArray *)subscriptions;

@end
