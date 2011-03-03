/* 
 ExploreViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/25/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "ExploreViewController.h"

@implementation ExploreViewController
@synthesize orderedKeys;
@synthesize exploreCell;

- (id)initWithStyle:(UITableViewStyle)style {
    if(self = [super initWithStyle:style]) {
		
		// Query for directory list
		[self requestForDirectories];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onExploreListUpdated:)
													 name: [Events DIRECTORY_LIST_UPDATED]
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

- (void)viewWillAppear:(BOOL)animated {

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	TT_RELEASE_SAFELY (orderedKeys);

    [super dealloc];
}

/*
 *	Request for all the directories.
 */
- (void)requestForDirectories {
	if ([[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine].xmppStream isConnected]) {
		[[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine] getDirectories];
	}
}

/*
 *	On explore list updated.
 */
- (void)onExploreListUpdated:(NSNotification *)notification
{
	NSLog(@"-------------Explore list updated-------------");
	NSArray *items = [notification object];
	
	if (items) {
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:DIR_ITEMS_SORTED_KEY 
																		ascending:YES 
																		 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
		
		[self setOrderedKeys:[items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]];
		[[self tableView] reloadData];
	}
}

/*
 *	On logout action.
 */
- (void)onLogoutButton
{
	//Clear the cache.
	[DatabaseAccess removeDatabase];
	
	//Reset the login settings.
	[LoginUtility resetLoginSettings];
	
	[[TTNavigator navigator] removeAllViewControllers];
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kAppRootURLPath]];
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
	DirectoryItem *item = [orderedKeys objectAtIndex: indexPath.row];
	
	if (item) {
		ExploreCellController *controller = [[ExploreCellController alloc] initWithNibName:@"ExploreCell" bundle:[NSBundle mainBundle]];
		
		// Set table cell
		cell = (UITableViewCell *)controller.view;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[[controller titleLabel] setText: [item title]];
		[[controller descriptionLabel] setText: [item description]];
		
		[controller release];			
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	DirectoryItem *item = [orderedKeys objectAtIndex: indexPath.row];

	if (item) {
		NSLog(@"Directory : %@ and title = %@", [item directoryId], [item title]);	
		ChannelListViewController *channelListViewController = [[[ChannelListViewController alloc] initWithStyle: UITableViewStylePlain 
																							   withDirectoryItem: item] autorelease];

		[[TTNavigator navigator].topViewController.navigationController pushViewController:channelListViewController animated:YES];
	}
	else {
		[tableView deselectRowAtIndexPath: indexPath animated: YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 42.0f;
	
	DirectoryItem *item = [orderedKeys objectAtIndex: indexPath.row];
	
	if (item) {
		if ([[item description] length] > 0) {
			UIFont *font = [UIFont fontWithName: @"Helvetica" size: 12];
			CGSize descriptionSize = [[item description] sizeWithFont: font 
														constrainedToSize: CGSizeMake(tableView.bounds.size.width - 18, 30)
															lineBreakMode: UILineBreakModeTailTruncation];
			
			result += (descriptionSize.height + [font xHeight]);
		}
	}
	
	return ((result < 52.0) ? 62.0 : result);
}

@end