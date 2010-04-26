//
//  DataEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RosterEngine;
@class FollowedItem;

@interface DataEngine : NSObject {
	NSMutableArray* following;
	RosterEngine *roster;
}

- (DataEngine*) initWithRosterEngine:(RosterEngine*)engine;

- (NSArray*) getFollowingList;
- (void) resortFollowingList;

- (FollowedItem*) getItemByIdent:(NSString*)ident;
- (NSArray*) listUsers;
- (NSArray*) listChannels;

@end
