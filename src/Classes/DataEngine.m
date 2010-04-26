//
//  DataEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "DataEngine.h"
#import "UserItem.h"
#import "ChannelItem.h"
#import "Events.h"
#import "RosterEngine.h"
#import "XMPPUser.h"

@implementation DataEngine

// Default constructor
- (DataEngine*) initWithRosterEngine:(RosterEngine*)engine {
	[super init];
	following = [[NSMutableArray alloc] init];
	roster = engine;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onInitialSubscriptionList:)
												 name:[Events INITIAL_SUBSCRIPTIONS]
											   object:nil];
	
	return self;
}

// Clean up when we're done
- (void) dealloc {
	[following removeAllObjects];
	following = nil;
	[super dealloc];
}

// React when we first get a list of subscriptions
- (void) onInitialSubscriptionList:(id)sender {
	// Add the users and channels we got from the server
	NSArray *items = (NSArray*)[(NSNotification*)sender object];
	[following removeAllObjects];
	[following addObjectsFromArray:items];
	
	// We also need UserItem objects for non-BC users
	for (XMPPUser *user in [roster unsortedUsers]) {
		NSString *jid = [user displayName];
		if ([self getItemByIdent:jid] == nil) {
			UserItem *user = [[UserItem alloc] init];
			user.ident = jid;
			[following addObject:user];
		}
	}
}

// Completely resort the following list
- (void) resortFollowingList {
	// Sort by PrivMsg count, then by ChanMsg count
}

// Construct the current Following List
- (NSArray*) getFollowingList {
	return following;
}

// Get a user or channel based on their ID
- (FollowedItem*) getItemByIdent:(NSString*)ident {
	for (FollowedItem *item in following) {
		if ([item.ident isEqualToString:ident]) {
			return item;
		}
	}
	return nil;
}

// Get a list of all followed users
- (NSArray*) listUsers {
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	for (FollowedItem *item in following) {
		if ([item isKindOfClass:[UserItem class]]) {
			[ret addObject:item];
		}
	}
	return ret;
}

// Get a list of all followed channels
- (NSArray*) listChannels {
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	for (FollowedItem *item in following) {
		if ([item isKindOfClass:[ChannelItem class]]) {
			[ret addObject:item];
		}
	}
	return ret;
}

@end
