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

#import "BuddycloudAppDelegate.h"
#import "BuddyRequestDelegate.h"

#import "XMPPEngine.h"
#import "LocationEngine.h"
#import "RosterEngine.h"

#import "FollowingViewController.h"

@implementation BuddycloudAppDelegate
@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;
@synthesize followingTableView;
@synthesize placesTableView;
@synthesize channelsTableView;

- (void)applicationDidFinishLaunching: (UIApplication*)application
{
	// View controllers
	vcFollowing = [[FollowingViewController alloc] initWithStyle:UITableViewStylePlain];
	ncFollowing = [[UINavigationController alloc] initWithRootViewController:vcFollowing];
	ncFollowing.tabBarItem.title = @"Following";
	[vcFollowing release];
	
	// Set up tab bar
	tabBarController = [[UITabBarController alloc] init];
	[tabBarController setViewControllers:[NSArray arrayWithObjects:ncFollowing, nil]];
	[window addSubview:tabBarController.view];

	// Engines
	xmpp = [[XMPPEngine alloc] init];
	location = (LocationEngine*)[[LocationEngine alloc] initWithXMPP:[xmpp client]];
	roster = [[RosterEngine alloc] initWithXMPP:[xmpp client]];
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	
	[super dealloc];
}

@end
