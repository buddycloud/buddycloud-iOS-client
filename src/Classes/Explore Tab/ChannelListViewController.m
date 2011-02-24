//
//  ChannelListViewController.m
//  Buddycloud
//
//  Created by Deminem on 12/25/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "ChannelListViewController.h"


@implementation ChannelListViewController

@synthesize directoryItem, orderedKeys, channelCell;

- (id)initWithStyle:(UITableViewStyle)style withDirectoryItem:(DirectoryItem *)item {
    if(self = [super initWithStyle:style]) {
		self.directoryItem = item;
		
		self.navigationItem.title = item.title;
		self.navigationController.navigationBar.tintColor = APPSTYLEVAR(navigationBarColor);
			
		// Query for all the channels list in specific directory.
		[self requestForDirectoryItems];
			
		//		[[TTNavigator navigator].URLMap from:kcreateNewAcctURLPath
		//					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate].atlasUrlHandler selector:@selector(createNewAccount)];
			
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onChannelListUpdated:)
													 name: [Events DIRECTORY_ITEM_LIST_UPDATED]
												   object: nil];
	}
	
	return self;
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	
	self.view.backgroundColor = APPSTYLEVAR(appBKgroundColor);
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.bottom - TABLE_DISPLAY_HEIGHT)] autorelease];
	self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
		
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:kcreateNewAcctURLPath];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	TT_RELEASE_SAFELY (orderedKeys);
	TT_RELEASE_SAFELY (channelCell);
	TT_RELEASE_SAFELY (directoryItem);

    [super dealloc];
}

/*
 *	Request for the directory items.
 */
- (void)requestForDirectoryItems {
	if ([[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine].xmppStream isConnected]) {
		[[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine] getDirectoryItems: [self.directoryItem directoryId]];
	}
}

/*
 *	On channel list updated.
 */
- (void)onChannelListUpdated:(NSNotification *)notification {
	NSLog(@"-------------onChannelListUpdated-------------");
	NSDictionary *item = [notification object];

	if (item) {
		NSString *directoryKey = [[item allKeys] objectAtIndex:0];
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:CHANNEL_ITEMS_SORTED_KEY 
																		ascending:YES 
																		 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
		
		[self setOrderedKeys: [[item valueForKey:directoryKey] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]];
		[[self tableView] reloadData];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [orderedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	ChannelItem *item = [orderedKeys objectAtIndex: indexPath.row];
	
	if (item) {
		if ([item isKindOfClass: [UserItem class]]) {
			
		}
		else if ([item isKindOfClass: [ChannelItem class]]) {
			ChannelCellController *controller = [[ChannelCellController alloc] initWithNibName:@"TopicCell" bundle:[NSBundle mainBundle]];
			
			// Set table cell
			cell = (UITableViewCell *)controller.view;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			// Set cell data
			ChannelItem *channelItem = (ChannelItem *)item;
			
			[[controller titleLabel] setText: [channelItem title]];
			[[controller rankLabel] setText: [NSString stringWithFormat: @"%@: %d", NSLocalizedString(@"Rank", @""), [channelItem rank]]];
			[[controller descriptionLabel] setText: [channelItem description]];
			
			// Adjust & set description
			if ([[channelItem description] length] > 0) {
				CGRect descriptionFrame = [[controller descriptionLabel] frame];
				CGSize descriptionSize = [[channelItem description] sizeWithFont: [[controller descriptionLabel] font] 
															constrainedToSize: descriptionFrame.size
																lineBreakMode: [[controller descriptionLabel] lineBreakMode]];
				
				[[controller descriptionLabel] setFrame: descriptionFrame];
			}
			
			[controller release];			
		}
	}	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	ChannelItem *item = [orderedKeys objectAtIndex: indexPath.row];
	
	if (item) {
		NSLog(@"Channel : %@ and title = %@", [item ident], [item title]);	
		ChannelDetailViewController *channelDetailViewController = [[[ChannelDetailViewController alloc] initWithChannelItem: item 
																								withChannelSectionSelected: CHANNEL_SEC_DETAIL] autorelease];
		
		[[TTNavigator navigator].topViewController.navigationController pushViewController:channelDetailViewController animated:YES];
	}
	else {
		[tableView deselectRowAtIndexPath: indexPath animated: YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 44.0f;
	
	ChannelItem *item = [orderedKeys objectAtIndex: indexPath.row];
	
	if (item) {
		if ([[item description] length] > 0) {
			UIFont *font = [UIFont fontWithName: @"Helvetica" size: 12];
			CGSize descriptionSize = [[item description] sizeWithFont: font 
													constrainedToSize: CGSizeMake(tableView.bounds.size.width - 18, 30)
														lineBreakMode: UILineBreakModeTailTruncation];
			
			result += (descriptionSize.height + [font xHeight]);
		}
	}
	
	return ((result < 54.0f) ? 64.0f : result);
}

@end
