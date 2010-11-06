/* 
 TabBarController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "TabBarController.h"

@implementation TabBarController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
	
	// Menu controllers are also shared - we only create one to show in each tab, so opening
	// these URLs will switch to the tab containing the menu
	
	TTNavigator* navigator = [TTNavigator navigator];
	TTURLMap* map = navigator.URLMap;
	[map from:kMenuPageURLPath toSharedViewController:[MenuController class]];
	
	[self setTabURLs:[NSArray arrayWithObjects:
					  [NSString stringWithFormat:kTabBarItemURLPath, MenuPageChannel],
					  [NSString stringWithFormat:kTabBarItemURLPath, MenuPagePlaces],
					  [NSString stringWithFormat:kTabBarItemURLPath, MenuPageBrowse],
					  [NSString stringWithFormat:kTabBarItemURLPath, MenuPageSettings],
					  nil]];
}

@end
