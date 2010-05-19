//
//  FollowingViewController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FollowingDataModel;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public FollowingViewController definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FollowingViewController : UITableViewController {
	FollowingDataModel *followingList;
	NSArray *orderedKeys;
	
	UITableViewCell *followerCell;
	UITableViewCell *channelCell;
}

@property(nonatomic, retain) NSArray *orderedKeys;
@property(nonatomic, assign) IBOutlet UITableViewCell *followerCell;
@property(nonatomic, assign) IBOutlet UITableViewCell *channelCell;

- (id)initWithStyle:(UITableViewStyle)style andDataModel:(FollowingDataModel *)dataModel;

@end
