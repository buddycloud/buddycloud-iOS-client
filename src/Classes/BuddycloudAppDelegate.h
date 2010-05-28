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

#import <UIKit/UIKit.h>

@class XMPPEngine;
@class PlaceEngine;
@class FollowingDataModel;
@class FollowingViewController;
#import "SettingsViewController.h" 

@interface BuddycloudAppDelegate: NSObject
{
	UIWindow *window;
	UITabBarController *tabBarController;
	UINavigationController *navigationController;
	
	UITableView *followingTableView;
	UITableView *postsTableView;
	
	XMPPEngine *xmppEngine;
	PlaceEngine *placeEngine;
	
	FollowingViewController *followingController;	
	SettingsViewController *settingsController;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet UITableView *followingTableView;
@property(nonatomic, retain) IBOutlet UITableView *postsTableView;
@property(nonatomic, retain) SettingsViewController *settingsController;
@property(nonatomic, retain) FollowingViewController *followingController;

- (FollowingDataModel *)followingDataModel;

@end
