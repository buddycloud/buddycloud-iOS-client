/*
 * Copyright (C) 2009 Jonathan Schleifer.
 *
 * This file is part of the Buddycloud iPhone client.
 *
 * Buddycloud for iPhone is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; version 2 only.
 *
 * Buddycloud for iPhone is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with Buddycloud for iPhone. If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>

@class XMPPEngine, RosterEngine, LocationEngine;
@class FollowingViewController;
#import "SettingsViewController.h" 

@interface BuddycloudAppDelegate: NSObject
{
	UIWindow *window;
	UITabBarController *tabBarController;
	UINavigationController *navigationController;
	UITableView *followingTableView, *placesTableView, *channelsTableView;
	
	NSArray *places, *nearby, *channels;
	
	XMPPEngine *xmpp;
	RosterEngine *roster;
	LocationEngine *location;
	
	FollowingViewController *vcFollowing;
	
	SettingsViewController *settingsController;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet UITableView *followingTableView;
@property(nonatomic, retain) IBOutlet UITableView *placesTableView;
@property(nonatomic, retain) IBOutlet UITableView *channelsTableView;
@property(nonatomic, retain) SettingsViewController *settingsController;
@property(nonatomic, retain) FollowingViewController *vcFollowing;

@end
