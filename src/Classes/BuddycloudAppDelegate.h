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
#import <CoreLocation/CoreLocation.h>

#import "XMPPJID.h"
#import "XMPPIQ.h"

@interface BuddycloudAppDelegate: NSObject <CLLocationManagerDelegate>
{
	UIWindow *window;
	UITabBarController *tabBarController;
	UINavigationController *navigationController;
	UITableView *followingTableView, *placesTableView, *channelsTableView;
	
	NSArray *places, *nearby, *channels;
	
	BOOL wasAuthedBefore, gotInitialPosition;
	CLLocationManager *locationManager;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet UITableView *followingTableView;
@property(nonatomic, retain) IBOutlet UITableView *placesTableView;
@property(nonatomic, retain) IBOutlet UITableView *channelsTableView;

- (IBAction)addFriend: (id)sender;
- (void)send501ForIQ: (XMPPIQ*)iq;
- (void)sendPingReplyTo: (XMPPJID*)from
	  withElementID: (NSString*)elementId;
- (void)sendVersionReplyTo: (XMPPJID*)from
	     withElementID: (NSString*)elementId;
- (void)answerDisco: (XMPPIQ*)iq;
- (void)sendLocationFromLocationManager: (CLLocationManager*)manager;
- (void)sendLocationFromLocationManager: (CLLocationManager*)manager
			     renewTimer: (BOOL)renew;
@end
