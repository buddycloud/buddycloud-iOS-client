//
//  FollowingDataModel.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FollowedItem;

@interface FollowingDataModel : NSObject {
	NSMutableDictionary *followingData;
}

- (NSArray *)unorderedKeys;
- (NSArray *)orderKeysByUpdated;

- (FollowedItem *)getItemByKey:(id)key;
- (FollowedItem *)getItemByIdent:(NSString *)ident;

- (void)followItem:(NSString *)item;

@end

@interface FollowingDataModel (PrivateAPI)

- (void)readDataFromStorage;
- (void)writeDataToStorage;

@end