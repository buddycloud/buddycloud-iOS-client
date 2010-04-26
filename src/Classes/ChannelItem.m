//
//  ChannelItem.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "ChannelItem.h"


@implementation ChannelItem
@synthesize title, description, affiliation, subscription, waitingMessages;

// Parse a channel affiliation string
+ (ChannelAffiliation) affiliationFromString:(NSString*)str {
	if ([str isEqualToString:@"none"]) {
		return CHANAFF_NONE;
	} else if ([str isEqualToString:@"owner"]) {
		return CHANAFF_OWNER;
	} else if ([str isEqualToString:@"moderator"]) {
		return CHANAFF_MODERATOR;
	} else if ([str isEqualToString:@"publisher"]) {
		return CHANAFF_PUBLISHER;
	} else if ([str isEqualToString:@"member"]) {
		return CHANAFF_MEMBER;
	} else {
		return CHANAFF_NONE;
	}
}

// Parse a channel subscription string
+ (ChannelSubscription) subscriptionFromString:(NSString*)str {
	if ([str isEqualToString:@"none"]) {
		return CHANSUB_NONE;
	} else if ([str isEqualToString:@"pending"]) {
		return CHANSUB_PENDING;
	} else if ([str isEqualToString:@"subscribed"]) {
		return CHANSUB_SUBSCRIBED;
	} else {
		return CHANSUB_NONE;
	}
}


@end
