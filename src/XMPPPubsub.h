//
//  XMPPPubsub.h
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPClient;

@interface XMPPPubsub : NSObject {
	id delegate;
	
	XMPPClient *xmppClient;
	
	NSString *serverName;
	
	int iqIdCounter;
}

@property(readonly) NSString *serverName;

- (id)initWithXMPPClient:(XMPPClient *)client toServer:(NSString *)serverName;
- (void)setDelegate:(id)delegate;

- (void)fetchOwnSubscriptions;

- (void)setAffiliationForUser:(NSString *)jid onNode:(NSString *)node toAffiliation:(NSString *)affiliation;

@end

@interface NSObject (XMPPPubsubDelegate)

- (void)xmppPubsub:(XMPPPubsub *)sender didReceiveOwnSubscriptions:(NSMutableArray *)subscriptions;

@end
