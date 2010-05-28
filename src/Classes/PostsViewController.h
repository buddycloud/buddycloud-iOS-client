//
//  PostsViewController.h
//  Buddycloud
//
//  Created by Ross Savage on 5/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FollowingDataModel;

@interface PostsViewController : UITableViewController {
	FollowingDataModel *followingData;
	
	NSMutableArray *postedItems;
	
	NSString *node;
}

@property(nonatomic, retain) NSString *node;

- (PostsViewController *)initWithNode:(NSString *)node andTitle:(NSString *)title;

- (void)addComment:(id)sender;

@end
