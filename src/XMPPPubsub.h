//
//  XMPPPubsub.h
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPModule.h"
#import "DDXML.h"

@class XMPPStream;
@class XMPPIQ;
@protocol XMPPPubsubDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub : XMPPModule {
	NSString *serverName;
	
	int iqIdCounter;
	
	NSMutableArray* collectionArray;
}

@property(readonly) NSString *serverName;

- (id)initWithStream:(XMPPStream *)xmppStream toServer:(NSString *)serverName;

- (void)fetchOwnSubscriptions;

- (void)fetchMetadataForNode:(NSString *)node;
- (void)fetchAffiliationsForNode:(NSString *)node;
- (void)fetchItemsForNode:(NSString *)node;

- (void)setSubscriptionForUser:(NSString *)jid onNode:(NSString *)node toSubscription:(NSString *)subscription;
- (void)setAffiliationForUser:(NSString *)jid onNode:(NSString *)node toAffiliation:(NSString *)affiliation;

- (void)subscribeToNode:(NSString *)node;
- (void)unsubscribeToNode:(NSString *)node;

- (void)publishItemToNode:(NSString *)node withItem:(NSXMLElement *)itemElement;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPPubsub definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPPubsub (PrivateAPI)

- (void)fetchOwnSubscriptionsAfter:(NSString *)node;
- (void)handleOwnSubscriptionsResult:(XMPPIQ *)iq;

- (void)handleNodeMetadataResult:(XMPPIQ *)iq;

- (void)fetchAffiliationsForNode:(NSString *)node afterJid:(NSString *)jid;
- (void)handleNodeAffiliationsResult:(XMPPIQ *)iq;

- (void)fetchItemsForNode:(NSString *)node afterItemId:(int)itemId;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubsub Delegate definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPPubsubDelegate
@optional

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSArray *)subscriptions;
- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveMetadata:(NSDictionary *)metadata forNode:(NSString *)node;
- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveAffiliations:(NSArray *)affiliations forNode:(NSString *)node;
- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveItem:(NSXMLElement *)item forNode:(NSString *)node;

@end
