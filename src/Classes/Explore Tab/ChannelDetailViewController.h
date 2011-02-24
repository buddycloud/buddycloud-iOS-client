//
//  ChannelDetailViewController.h
//  Buddycloud
//
//  Created by Deminem on 12/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelWallDataSource.h"
#import "ChannelDetailInoDataSource.h"

#import "ChannelItem.h"

typedef enum {
	CHANNEL_SEC_NONE = 0,
	CHANNEL_SEC_WALL,
	CHANNEL_SEC_PRIVATE,
	CHANNEL_SEC_DETAIL,
} ChannelSectionPage;

@interface ChannelDetailViewController : TTViewController <UITableViewDelegate> {
	
	UIView* _headerView;
	UIView* _footerView;
	UITableView *_tableView;
	UISegmentedControl *_segmentedControl;

	ChannelItem *_channelItem;
	ChannelSectionPage _selectedSection;
}

@property (nonatomic, retain) IBOutlet UIView* headerView;
@property (nonatomic, retain) IBOutlet UIView* footerView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) ChannelItem *channelItem;
@property (nonatomic) ChannelSectionPage selectedSection;

- (void)createSectionPage:(NSInteger)sectionPage;
- (void)displaySectionPage:(UIViewController *)sectionViewController;
- (IBAction)toggleChannelSections:(id)sender;

- (id)initWithChannelItem:(ChannelItem *)item;
- (id)initWithChannelItem:(ChannelItem *)item withChannelSectionSelected:(ChannelSectionPage)sectionPage;



@end
