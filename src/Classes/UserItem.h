//
//  RosterItem.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FollowedItem.h"

@class XMPPJID;
@class GeoLocation;
@class ChannelItem;

typedef enum {
	PRESSUB_REMOVE = -1,
	PRESSUB_NONE,
	PRESSUB_TO,
	PRESSUB_FROM,
	PRESSUB_BOTH
} PresenceSubscription;

@interface UserItem : FollowedItem {
	PresenceSubscription subscription;
	
	GeoLocation *geoCurrent;
	GeoLocation *geoPrevious;
	GeoLocation *geoFuture;
	
	ChannelItem *channel;
	int waitingMessages;
}

@property (nonatomic) PresenceSubscription subscription;
@property (nonatomic, retain) GeoLocation *geoCurrent;
@property (nonatomic, retain) GeoLocation *geoPrevious;
@property (nonatomic, retain) GeoLocation *geoFuture;
@property (nonatomic, retain) ChannelItem *channel;
@property (nonatomic) int waitingMessages;

+ (PresenceSubscription)subscriptionFromString:(NSString *)str;

@end
