//
//  FollowedItem.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowedItem.h"

@implementation FollowedItem
@synthesize lastUpdated;
@synthesize ident, title, description;

- (FollowedItem *)init
{
	[super init];
	lastUpdated = [[NSDate alloc] init];
	
	return self;
}

- (NSComparisonResult)compareUpdate:(FollowedItem *)other
{
	return [[other lastUpdated] compare: lastUpdated];
}

@end
