/*
 * Copyright (c) 2009, Jonathan Schleifer <js@webkeks.org>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice is present in all copies.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#import "BuddycloudAppDelegate.h"
#import "BuddyRequestDelegate.h"

#import "XMPPEngine.h"
#import "PlaceEngine.h"

#import "FollowingViewController.h"

@implementation BuddycloudAppDelegate
@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;
@synthesize followingTableView;
@synthesize placesTableView;
@synthesize channelsTableView;
@synthesize settingsController;
@synthesize followingController;

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
	// Engines
	xmppEngine = [[XMPPEngine alloc] init];
	[xmppEngine setPassword: @"iphone"];
	
	placeEngine = [[PlaceEngine alloc] initWithStream: [xmppEngine xmppStream] toServer: @"butler.buddycloud.com"];
	
	// View controllers
	self.followingController = [[[FollowingViewController alloc] initWithStyle: UITableViewStylePlain andDataModel: (FollowingDataModel *)xmppEngine] autorelease];
	UINavigationController *ncFollowing = [[[UINavigationController alloc] initWithRootViewController:followingController] autorelease];
	
	self.settingsController = [[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	UINavigationController *settingsNavigationController = [[[UINavigationController alloc] initWithRootViewController:self.settingsController] autorelease];
	
	// Set up tab bar
	self.tabBarController = [[UITabBarController alloc] init];
	[self.tabBarController setViewControllers:[NSArray arrayWithObjects:ncFollowing, settingsNavigationController, nil]];
	[window addSubview:tabBarController.view];
	
	// Start connection
	[xmppEngine connect];
	
	return YES;
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	
	[super dealloc];
}

@end
