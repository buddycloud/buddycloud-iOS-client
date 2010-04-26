//
//  RosterItem.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FollowedItem.h"

@class GeoLocation;
@class ChannelItem;

@interface UserItem : FollowedItem {
	NSString *jid;
	NSString *status;
	GeoLocation *geoCurrent;
	GeoLocation *geoPrevious;
	GeoLocation *geoFuture;
	ChannelItem *channel;
	int waitingMessages;
}

@property (nonatomic, retain) NSString *jid;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) GeoLocation *geoCurrent;
@property (nonatomic, retain) GeoLocation *geoPrevious;
@property (nonatomic, retain) GeoLocation *geoFuture;
@property (nonatomic, retain) ChannelItem *channel;
@property (nonatomic) int waitingMessages;

@end
