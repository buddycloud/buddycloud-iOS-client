//
//  XMPPEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPClient;
@class XMPPIQ, XMPPJID;

@interface XMPPEngine : NSObject {
	XMPPClient *xmpp;
	bool wasAuthedBefore;
}

- (XMPPClient*) client;

- (void)send501ForIQ: (XMPPIQ*)iq;
- (void)sendPingReplyTo: (XMPPJID*)from
		  withElementID: (NSString*)elementId;
- (void)sendVersionReplyTo: (XMPPJID*)from
			 withElementID: (NSString*)elementId;
- (void)answerDisco: (XMPPIQ*)iq;

@end
