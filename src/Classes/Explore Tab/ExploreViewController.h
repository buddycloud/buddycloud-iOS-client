/* 
 ExploreViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/25/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "ExploreCellController.h"
#import "ChannelListViewController.h"
#import "Events.h"
#import "DirectoryItem.h"
#import "ChannelItem.h"

#define DIR_ITEMS_SORTED_KEY  @"title"

@interface ExploreViewController :  UITableViewController {
	NSArray *orderedKeys;
	
	UITableViewCell *exploreCell;
}

@property(nonatomic, retain) NSArray *orderedKeys;
@property(nonatomic, assign) IBOutlet UITableViewCell *exploreCell;

- (id)initWithStyle:(UITableViewStyle)style;
- (void)requestForDirectories;

@end
