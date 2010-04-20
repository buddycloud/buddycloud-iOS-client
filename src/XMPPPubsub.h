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
	
	XMPPClient *client;
	
	NSString *server;
}

- (id)initWithXMPPClient:(XMPPClient *)xmppClient delegate:(id)delegate;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSString *)pubsubServer;
- (void)setPubsubServer:(NSString *)server;

@end
