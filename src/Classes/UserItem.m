//
//  RosterItem.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem
@synthesize subscription, geoCurrent, geoPrevious, geoFuture, channel, waitingMessages;

+ (PresenceSubscription)subscriptionFromString:(NSString *)str
{
	if ([str isEqualToString:@"none"]) {
		return PRESSUB_NONE;
	} else if ([str isEqualToString:@"to"]) {
		return PRESSUB_TO;
	} else if ([str isEqualToString:@"from"]) {
		return PRESSUB_FROM;
	} else if ([str isEqualToString:@"both"]) {
		return PRESSUB_BOTH;
	} else if ([str isEqualToString:@"remove"]) {
		return PRESSUB_REMOVE;
	} else {
		return PRESSUB_NONE;
	}
}

@end
