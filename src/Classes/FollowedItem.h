//
//  FollowedItem.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FollowedItem : NSObject {
	NSString *ident;
	NSDate *lastUpdated;
}

@property (nonatomic,retain) NSString *ident;
@property (nonatomic,retain) NSDate *lastUpdated;

- (NSComparisonResult) compareAge:(FollowedItem*)item;

@end
