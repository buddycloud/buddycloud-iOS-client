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
@synthesize settingsController;
@synthesize vcFollowing;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	if ([[url host] isEqualToString:@"channel"])
	{
		// Jump to page of chanel
		NSLog(@"channel");
	}
						
		return YES;
}

- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
	// View controllers
	self.vcFollowing = [[[FollowingViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	UINavigationController *ncFollowing = [[[UINavigationController alloc] initWithRootViewController:vcFollowing] autorelease];
	
	self.settingsController = [[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	UINavigationController *settingsNavigationController = [[[UINavigationController alloc] initWithRootViewController:self.settingsController] autorelease];
	
	// Set up tab bar
	self.tabBarController = [[UITabBarController alloc] init];
	[self.tabBarController setViewControllers:[NSArray arrayWithObjects:ncFollowing, settingsNavigationController, nil]];
	[window addSubview:tabBarController.view];
	
	// Engines
	xmpp = [[XMPPEngine alloc] init];
	location = (LocationEngine*)[[LocationEngine alloc] initWithXMPP:[xmpp client]];
	roster = [[RosterEngine alloc] initWithXMPP:[xmpp client]];
	
	if (launchOptions != nil) {
//		NSString* launchUrl = [launchOptions objectForKey:@""]
	}
	
	return YES;
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	
	[super dealloc];
}

@end
