//
//  ChannelDetailViewController.m
//  Buddycloud
//
//  Created by Deminem on 12/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "ChannelDetailViewController.h"

@implementation ChannelDetailViewController

@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize segmentedControl = _segmentedControl;
@synthesize tableView = _tableView;
@synthesize channelItem = _channelItem, selectedSection = _selectedSection;

- (id)initWithChannelItem:(ChannelItem *)item {
	
	// If it's not defined, by defualt channel wall will be selected.
	if (self = [self initWithChannelItem: item withChannelSectionSelected: CHANNEL_SEC_WALL]) {
		
	}
	
	return self;
}

- (id)initWithChannelItem:(ChannelItem *)item withChannelSectionSelected:(ChannelSectionPage)sectionPage {
    if(self = [super initWithNibName: @"ChannelDetailViewController" bundle: [NSBundle mainBundle]]) {
		_channelItem = item;
		_selectedSection = sectionPage;
		
		self.title = [_channelItem title];
		self.navigationBarTintColor = APPSTYLEVAR(navigationBarColor);
		self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc] initWithTitle: @"Root"
										  style: UIBarButtonItemStyleBordered
										 target: nil
										 action: nil] autorelease];
	}
	
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
	TT_RELEASE_SAFELY(_footerView);
	TT_RELEASE_SAFELY(_headerView);
	TT_RELEASE_SAFELY(_tableView);
	TT_RELEASE_SAFELY(_segmentedControl);
	
	[super dealloc];
}

#define HEADER_HEIGHT	44.0
#define MIDDLEVIEW_TAG	8888

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = APPSTYLEVAR(appBKgroundColor);
	self.headerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, HEADER_HEIGHT);	
	[self.view addSubview: self.headerView];
	
	[self.segmentedControl setSelectedSegmentIndex: _selectedSection];
	[self.segmentedControl setSelected:YES];
	
	//Show the default page.
	[self createSectionPage: _selectedSection]; 	
}

- (IBAction)toggleChannelSections:(id)sender
{
	UISegmentedControl *segControl = sender;
	NSInteger sectionIndex = segControl.selectedSegmentIndex + 1;
	
	[self createSectionPage: sectionIndex];
}

- (void)createSectionPage:(NSInteger)sectionPage	
{
	UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
	//NSLog(@"Section : %d", sectionPage);
	
	switch (sectionPage)
	{
		case CHANNEL_SEC_WALL:	// Channel Wall
		{
			ChannelWallDataSource *channelWallDataSource = [[[ChannelWallDataSource alloc] initWithPostItems:nil withNode:nil] autorelease];
			_tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0 - 150.0)] autorelease];
			_tableView.backgroundColor = [UIColor clearColor];
			_tableView.delegate = channelWallDataSource;
			_tableView.rowHeight = YES;
			_tableView.dataSource = [channelWallDataSource retain];
			
			[viewController.view addSubview: _tableView];

			break;
		}
			
		case CHANNEL_SEC_PRIVATE: // Channel Private
		{	
			//TODO: Channel Private Page.
			break;
		}
			
		case CHANNEL_SEC_DETAIL:	// Channel Detail
		{
			ChannelDetailInoDataSource *channelPrivateDataSource = [[ChannelDetailInoDataSource alloc] initWithNodeItem:_channelItem];
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0 - 140.0) style:UITableViewStyleGrouped];
			_tableView.backgroundColor =  RGBCOLOR(196.0, 207.0, 210.0);
			_tableView.delegate = channelPrivateDataSource;
			_tableView.dataSource = [channelPrivateDataSource retain];
			
			channelPrivateDataSource._tableView = [_tableView retain];
			[viewController.view addSubview: _tableView];
			
			break;
		}
	}
	
	//Show the section view
	[self displaySectionPage: viewController];
}

- (void)displaySectionPage:(UIViewController *)sectionViewController {
	
	UIView *middleView = (UIView *)[self.view viewWithTag:MIDDLEVIEW_TAG];
	
	if (middleView != nil) {
		[middleView removeFromSuperview];
	}
	
	sectionViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - HEADER_HEIGHT);
 	[sectionViewController.view setTag: MIDDLEVIEW_TAG];
	[self.view addSubview: sectionViewController.view];
}


@end
