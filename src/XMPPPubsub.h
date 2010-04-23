//
//  XMPPPubsub.h
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@class MulticastDelegate;
@class XMPPClient;
@class XMPPIQ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub : NSObject {
	MulticastDelegate *multicastDelegate;
	
	XMPPClient *xmppClient;
	NSString *serverName;
	
	int iqIdCounter;
	
	NSMutableArray* collectionArray;
}

@property(readonly) NSString *serverName;

- (id)initWithXMPPClient:(XMPPClient *)client toServer:(NSString *)serverName;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (void)fetchOwnSubscriptions;

- (void)fetchMetadataForNode:(NSString *)node;
- (void)fetchAffiliationsForNode:(NSString *)node;
- (void)fetchItemsForNode:(NSString *)node;

- (void)setSubscriptionForUser:(NSString *)jid onNode:(NSString *)node toSubscription:(NSString *)subscription;
- (void)setAffiliationForUser:(NSString *)jid onNode:(NSString *)node toAffiliation:(NSString *)affiliation;

- (void)publishItemToNode:(NSString *)node withItem:(NSXMLElement *)itemElement;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub (PrivateAPI)

- (void)fetchOwnSubscriptionsAfter:(NSString *)node;
- (void)handleOwnSubscriptionsResult:(XMPPIQ *)iq;

- (void)fetchAffiliationsForNode:(NSString *)node afterJid:(NSString *)jid;
- (void)handleNodeAffiliationsResult:(XMPPIQ *)iq;

- (void)fetchItemsForNode:(NSString *)node afterItemId:(int)itemId;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubsub Delegate definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (XMPPPubsubDelegate)

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSMutableArray *)subscriptions;
- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveAffiliations:(NSMutableArray *)affiliations forNode:(NSString *)node;

@end
