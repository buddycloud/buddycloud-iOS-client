//
//  FollowingViewController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowingViewController : UITableViewController {
	NSMutableArray *following;
	UITableViewCell *followerCell;
}
@property (nonatomic, assign) IBOutlet UITableViewCell *followerCell;

@end
