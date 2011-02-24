/* 
 MenuController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Three20/Three20.h>
#import "FollowingViewController.h"
#import "ExploreViewController.h"
#import "SettingsViewController.h"

typedef enum {
	MenuPageNone = 0,
	MenuPageFollowing,
	MenuPageBrowse,
	MenuPagePlaces,
	MenuPageSettings,
} MenuPage;

@interface MenuController : TTViewController {
	
	MenuPage _page;
	UIViewController *selectedViewController;
}

@property(nonatomic) MenuPage page;
@property(nonatomic, retain) UIViewController *selectedViewController;

@end
