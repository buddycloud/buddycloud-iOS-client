//
//  FollowedItem.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FollowedItem : NSObject {
	NSDate *lastUpdated;
	NSString *ident;
	
	NSString *title;
	NSString *description;
}

@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSString *ident;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;

- (NSComparisonResult)compareUpdate:(FollowedItem *)other;

@end
