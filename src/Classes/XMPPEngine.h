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
#import "RFSRVResolver.h"

#define usernameKey	@"usernameKey"
#define passwordKey	@"passwordKey"

@class XMPPStream;
@class XMPPReconnect;
@class XMPPRoster;
@class XMPPPubsub;


@class XMPPJID;
@class XMPPIQ;
@class FollowedItem;
@class ChannelItem;
@class DirectoryItem;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPEngine : FollowingDataModel {
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
	XMPPRoster *xmppRoster;
	XMPPPubsub *xmppPubsub;

	NSString *password;
	BOOL isNewUserRegisteration;
	BOOL authenticateAnonymously;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	bool isConnectionCold;
	bool isPubsubAddedToRoster;
	superlong lastItemIdReceived;
	
	NSString *usersBroadLocation;
}

@property(nonatomic, retain) XMPPStream *xmppStream;
@property(nonatomic, retain) XMPPReconnect *xmppReconnect;
@property(nonatomic, retain) XMPPRoster *xmppRoster;
@property(nonatomic, retain) NSString *password;
@property(nonatomic) BOOL isNewUserRegisteration;
@property(nonatomic) BOOL authenticateAnonymously;
@property(readonly) superlong lastItemIdReceived;

- (void)connect;
- (void)disconnect;

- (BOOL)postChannelText:(NSString *)text toNode:(NSString *)node;
- (BOOL)postChannelText:(NSString *)text toNode:(NSString *)node inReplyTo:(long long)entryId;

- (void)getDirectories;
- (void)getDirectoryItems:(NSString *)sId ;
- (void)fetechMetadataForNode:(NSString *)node;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPEngine (PrivateAPI)

- (void)sendPresence;
- (void)sendPresenceToPubsubWithLastItemId:(int)itemId;

- (void)sendPingResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId;
- (void)sendVersionResultTo:(XMPPJID *)recipient withIQId:(NSString *)iqId;
- (void)sendFeatureDiscovery:(XMPPIQ *)iq;

- (void)handleDirectoryItems:(XMPPIQ *)iq;

@end

