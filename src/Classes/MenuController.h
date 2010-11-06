/* 
 MenuController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Three20/Three20.h>
#import "FollowingViewController.h"
#import "SettingsViewController.h"

typedef enum {
	MenuPageNone,
	MenuPageChannel,
	MenuPagePlaces,
	MenuPageBrowse,
	MenuPageSettings,
} MenuPage;

@interface MenuController : TTViewController {
	MenuPage _page;
}

@property(nonatomic) MenuPage page;

@end
