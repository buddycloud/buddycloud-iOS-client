//
//  Events.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "Events.h"


@implementation Events

+ (NSString *) FOLLOWINGLIST_UPDATED {
	return @"FOLLOWINGLIST_UPDATED";
}

+ (NSString *) GEOLOCATION_CHANGED {
	return @"GEOLOCATION_CHANGED";
}

+ (NSString *) AT_FUTURE_GEOLOCATION {
	return @"AT_FUTURE_GEOLOCATION";
}

+ (NSString *) PLACE_CHANGED {
	return @"PLACE_CHANGED";
}

+ (NSString *) BROAD_LOCATION_CHANGED {
	return @"BROAD_LOCATION_CHANGED";
}

+ (NSString *) USER_REGISTRATION_SUCCESS {
	return @"USER_REGISTRATION_SUCCESS";
}

+ (NSString *) USER_REGISTRATION_FAILED {
	return @"USER_REGISTRATION_FAILED";
}

+ (NSString *) USER_LOGGED_IN_SUCCESS {
	return @"USER_LOGGED_IN_SUCCESS";
}

+ (NSString *) USER_LOGGED_IN_FAILED {
	return @"USER_LOGGED_IN_FAILED";
}

@end
