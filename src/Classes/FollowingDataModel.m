//
//  FollowingDataModel.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingDataModel.h"
#import "FollowedItem.h"
#import "Events.h"


@implementation FollowingDataModel

// Default constructor
- (FollowingDataModel *)init
{
	[super init];
	
	followingData = [[NSMutableDictionary alloc] initWithCapacity: 1];
	
	[self readDataFromStorage];
	
	return self;
}

// Clean up when we're done
- (void)dealloc
{
	[self writeDataToStorage];
	
	[followingData removeAllObjects];
	followingData = nil;
	
	[super dealloc];
}

- (NSArray *)unorderedKeys
{
	return [followingData allKeys];
}

- (NSArray *)orderKeysByUpdated
{
	return [followingData keysSortedByValueUsingSelector:@selector(compareUpdate:)];
}

- (FollowedItem *)getItemByKey:(id)key
{
	return (FollowedItem *) [followingData objectForKey: key];
}

- (FollowedItem *)getItemByIdent:(NSString*)ident {
	for (id key in followingData) {
		FollowedItem *item = [followingData objectForKey: key];
		
		if ([item.ident isEqualToString:ident]) {
			return item;
		}
	}
	
	return nil;
}

- (void)readDataFromStorage
{
}

- (void)writeDataToStorage 
{
}

@end
