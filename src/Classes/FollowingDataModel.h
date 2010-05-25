//
//  FollowingDataModel.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseAccess.h"

@class PostItem;
@class FollowedItem;

@interface FollowingDataModel : DatabaseAccess {
	NSMutableDictionary *followingData;
}

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion;

- (BOOL)insertPost:(PostItem *)post;



- (NSArray *)unorderedKeys;
- (NSArray *)orderKeysByUpdated;

- (FollowedItem *)getItemByKey:(id)key;
- (FollowedItem *)getItemByIdent:(NSString *)ident;

- (void)followItem:(NSString *)item;

@end
