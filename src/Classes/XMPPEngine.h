//
//  XMPPEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FollowingDataModel.h"
#import "PostItem.h"

@class XMPPStream;
@class XMPPRoster;
@class XMPPPubsub;
@class XMPPJID;
@class XMPPIQ;
@class FollowedItem;
@class ChannelItem;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPEngine : FollowingDataModel {
	XMPPStream *xmppStream;
	XMPPRoster *xmppRoster;
	XMPPPubsub *xmppPubsub;
	
	NSString *password;
	
	bool isConnectionCold;
	bool isPubsubAddedToRoster;
	superlong lastItemIdReceived;
}

@property(nonatomic, retain) XMPPStream *xmppStream;
@property(nonatomic, retain) XMPPRoster *xmppRoster;
@property(nonatomic, retain) NSString *password;
@property(readonly) superlong lastItemIdReceived;

- (void)connect;
- (void)disconnect;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPEngine (PrivateAPI)

- (ChannelItem *)getChannelItemForFollowedItem:(FollowedItem *)item;

- (void)sendPresenceToPubsubWithLastItemId:(int)itemId;

- (void)sendPingResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId;
- (void)sendVersionResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId;
- (void)sendFeatureDiscovery:(XMPPIQ *)iq;

@end

