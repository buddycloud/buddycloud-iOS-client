//
//  FollowingDataModel.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseAccess.h"
#import "MulticastDelegate.h"

@class PostItem;
@class FollowedItem;
@class ChannelItem;

@interface FollowingDataModel : DatabaseAccess {
	NSMutableDictionary *followingData;
	
	id multicastDelegate;
}

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion;

- (BOOL)insertPost:(PostItem *)post;
- (NSArray *)selectPostsForNode:(NSString *)node;
- (BOOL)doesTopicPostExist:(long long)entryId forNode:(NSString *)node;




- (ChannelItem *)getChannelItemForFollowedItem:(FollowedItem *)item;

- (NSArray *)unorderedKeys;
- (NSArray *)orderKeysByUpdated;

- (FollowedItem *)getItemByKey:(id)key;
- (FollowedItem *)getItemByIdent:(NSString *)ident;

- (void)followItem:(NSString *)item;

@end


@protocol FollowingDataModelDelegate
@optional

- (void)followingDataModel:(FollowingDataModel *)model didInsertPost:(PostItem *)post;
- (void)followingDataModel:(FollowingDataModel *)model didRemovePost:(PostItem *)post;

@end