//
//  ChannelListViewController.h
//  Buddycloud
//
//  Created by Deminem on 12/25/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryItem.h"
#import "ChannelItem.h"
#import "UserItem.h"
#import "ChannelCellController.h"
#import "ChannelDetailViewController.h"

#define CHANNEL_ITEMS_SORTED_KEY  @"title"

@interface ChannelListViewController : UITableViewController {
	DirectoryItem *directoryItem;
	
	NSArray *orderedKeys;	
	UITableViewCell *channelCell;
}

@property(nonatomic, retain) DirectoryItem *directoryItem;
@property(nonatomic, retain) NSArray *orderedKeys;
@property(nonatomic, assign) IBOutlet UITableViewCell *channelCell;

- (id)initWithStyle:(UITableViewStyle)style withDirectoryItem:(DirectoryItem *)item;
- (void)requestForDirectoryItems;

@end
