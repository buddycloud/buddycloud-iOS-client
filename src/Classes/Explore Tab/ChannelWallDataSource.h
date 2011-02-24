/* 
 ChannelWallDataSource.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "ChannelTopicCell.h"

@class ChannelTopicCell;

@interface ChannelWallDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {

	NSMutableArray *_postedItems;
	UITableView *_tableView;
	
	NSString *_node;
}

@property(nonatomic, retain) NSString *_node;
@property (nonatomic, retain) NSMutableArray *_postedItems;
@property (nonatomic, retain) UITableView *_tableView;

- (id)initWithPostItems:(NSMutableArray *)items withNode:(NSString *)node;
- (UIView *)getTopicCellView:(NSInteger)section;

@end
