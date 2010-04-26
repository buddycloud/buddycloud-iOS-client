//
//  Events.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "Events.h"


@implementation Events

+ (NSString *) ROSTER_UPDATED {
	return @"ROSTER_UPDATED";
}

+ (NSString *) LOCATION_CHANGED {
	return @"LOCATION_CHANGED";
}

+ (NSString *) INITIAL_SUBSCRIPTIONS {
	return @"INITIAL_SUBSCRIPTIONS";
}

+ (NSString *) FOLLOWINGLIST_UPDATED {
	return @"FOLLOWINGLIST_UPDATED";
}

@end
