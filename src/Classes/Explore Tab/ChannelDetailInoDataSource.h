/* 
 ChannelDetailInoDataSource.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "ChannelDetailHeader.h"
#import "ChannelItem.h"
#import "CustomizedTableCell.h"

@class ChannelDetailHeader;

typedef enum {
	CHANNEL_DETAIL_INFO,
	CHANNEL_DETAIL_PRODUCER_OTPTIONS,
	CHANNEL_DETAIL_FOR_EVERYONE,
	CHANNEL_DETAIL_LOOKUP
} ChannelDetailSections;

@interface ChannelDetailInoDataSource : TTView <UITableViewDataSource, UITableViewDelegate, CustomizedTableCellDelegate> {

	ChannelDetailItem *channelDetailItem;
	UITableView *_tableView;
	
	NSMutableDictionary *_nodeInfoDict;
}

@property (nonatomic, retain) ChannelDetailItem *channelDetailItem;
@property (nonatomic, retain) UITableView *_tableView;
@property (nonatomic, retain) NSMutableDictionary *nodeInfoDict;

- (id)initWithNodeItem:(ChannelItem *)item;
- (void)requestForChannelDetails;

- (UIView *)getChannelInfoDetails;
- (NSMutableDictionary *)getSectionItems:(ChannelDetailSections)section;

@end
