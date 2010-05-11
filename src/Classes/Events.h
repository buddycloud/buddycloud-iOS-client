//
//  Events.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Events : NSObject {

}

// Fires when the location engine has a new location for us
+ (NSString *) LOCATION_CHANGED;

// Fires when we first get a list of user/channel subscriptions from pubsub
+ (NSString *) INITIAL_SUBSCRIPTIONS;

// Fires when the items in the following list or their order has changed
+ (NSString *) FOLLOWINGLIST_UPDATED;

@end
