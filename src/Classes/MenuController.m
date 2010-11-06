/* 
 MenuController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "MenuController.h"

@implementation MenuController

@synthesize page = _page;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (NSString*)nameForMenuPage:(MenuPage)page {
	switch (page) {
		case MenuPageChannel:
			return NSLocalizedString(channel, @"");
		case MenuPagePlaces:
			return NSLocalizedString(places, @"");
		case MenuPageBrowse:
			return NSLocalizedString(browse, @"");
		case MenuPageSettings:
			return NSLocalizedString(settings, @"");

		default:
			return @"";
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithMenuPage:(MenuPage)page {
	if (self = [super init]) {
		self.page = page;
	}
	return self;
}

- (id)init {
	if (self = [super init]) {
		_page = MenuPageNone;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPage:(MenuPage)page {
	_page = page;
	
	self.title = [self nameForMenuPage:page];

	//Channel Page
	if (_page == MenuPageChannel) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[self nameForMenuPage:page] image:[UIImage imageNamed:@"tabbar-gs-following.png"] tag:MenuPageChannel] autorelease];
		FollowingViewController *pageViewController = [[FollowingViewController alloc] initWithStyle: UITableViewStylePlain
																						andDataModel: (FollowingDataModel *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine]];	
		
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd 
																				   target: pageViewController 
																				   action: @selector(onAddButton)];
		pageViewController.view.frame = TTScreenBounds();
 		[self.view addSubview:pageViewController.tableView];
		
		self.navigationItem.title = NSLocalizedString(following, @"");
		self.navigationItem.rightBarButtonItem = addButton;
	} 
	
	//Places Page
	else if (_page == MenuPagePlaces) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[self nameForMenuPage:page] image:[UIImage imageNamed:@"tabbar-gs-places.png"] tag:MenuPagePlaces] autorelease];

	}

	//Browse Page
	else if (_page == MenuPageBrowse) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[self nameForMenuPage:page] image:[UIImage imageNamed:@"tabbar-gs-browse.png"] tag:MenuPageBrowse] autorelease];
		
	}

	//Settings Page
	else if (_page == MenuPageSettings) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[self nameForMenuPage:page] image:[UIImage imageNamed:@"tabbar-gs-settings.png"] tag:MenuPageSettings] autorelease];
		
		SettingsViewController *pageViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
		pageViewController.view.frame = TTScreenBounds();
 		[self.view addSubview:pageViewController.tableView];
	}
}

@end
