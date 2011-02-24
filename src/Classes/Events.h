//
//  Events.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Events : NSObject

// Fires when the items in the following list or their order has changed
+ (NSString *) FOLLOWINGLIST_UPDATED;

// Users current geolocation changes
+ (NSString *) GEOLOCATION_CHANGED;

// Fires when current geolocation matches future geolocation
+ (NSString *) AT_FUTURE_GEOLOCATION;

// Fires when the place engine has a new location for us
+ (NSString *) PLACE_CHANGED;

// Fires when the broad location of the user changes
+ (NSString *) BROAD_LOCATION_CHANGED;

// Fires when the new user registration is successfull.
+ (NSString *) USER_REGISTRATION_SUCCESS;

// Fires when the new user registration is failed.
+ (NSString *) USER_REGISTRATION_FAILED;

// Fires when the user successfully logged in.
+ (NSString *) USER_LOGGED_IN_SUCCESS;

// Fires when the user logged in failed.
+ (NSString *) USER_LOGGED_IN_FAILED;

// Fires when the diretcories list updated.
+ (NSString *) DIRECTORY_LIST_UPDATED;

// Fires when the directory items list updated.
+ (NSString *) DIRECTORY_ITEM_LIST_UPDATED;

// Fires when the channel metadata item updated.
+ (NSString *) CHANNEL_METADATA_ITEM_UPDATED;

@end
