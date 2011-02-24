//
//  ChannelItem.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FollowedItem.h"
#import "Geolocation.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel affiliation enumeration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
	CHANAFF_NONE = 0,
	CHANAFF_OWNER,
	CHANAFF_MODERATOR,
	CHANAFF_PUBLISHER,
	CHANAFF_MEMBER
} ChannelAffiliation;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel subscription enumeration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
	CHANSUB_NONE = 0,
	CHANSUB_PENDING,
	CHANSUB_SUBSCRIBED
} ChannelSubscription;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel subscription
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ChannelItem : FollowedItem {
	ChannelAffiliation affiliation;
	ChannelSubscription subscription;
	
	int rank;
}

@property (nonatomic) ChannelAffiliation affiliation;
@property (nonatomic) ChannelSubscription subscription;
@property (nonatomic) int rank;

+ (ChannelAffiliation) affiliationFromString:(NSString*)str;
+ (ChannelSubscription) subscriptionFromString:(NSString*)str;

+ (NSString *) stringFromAffiliation:(ChannelAffiliation)channelAffiliation;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel Detail Item
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ChannelDetailItem : ChannelItem {

	NSString *owner;
	int popularity;
	int subscribers;
	
	//Affiliation Info <jid,ChannelAffiliation> 
	NSMutableDictionary *channelAffilationInfo;
	
	GeoLocationCordinateInfo *geoCordinateInfo;
}

@property (nonatomic, retain) NSString *owner;
@property (nonatomic) int popularity;
@property (nonatomic) int subscribers;
@property (nonatomic, retain) NSMutableDictionary *channelAffilationInfo;
@property (nonatomic, retain) GeoLocationCordinateInfo *geoCordinateInfo;

- (id)initWithChannelItem:(ChannelItem *)item;
- (id)initWithOwner:(NSString *)sOwner withPopularity:(int)iPopularity withSubscribers:(int)iSubscribers;
- (void)setChannelItem:(ChannelItem *)channelItem;
- (NSInteger)getNoOfAffiliationByType:(ChannelAffiliation)channelAffiliation;

@end


