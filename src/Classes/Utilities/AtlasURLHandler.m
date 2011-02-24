/* 
 AtlasURLHandler.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 1/11/11.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "AtlasURLHandler.h"


@implementation AtlasURLHandler

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LoginViewController - Login Network Methods.
//////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController *)showNetworkLogin:(NSInteger)networkId {
	LoginViewController *loginViewController = [[[LoginViewController alloc] initWithTitle:NSLocalizedString(createAccount, @"")
																			 withNetworkID:networkId] autorelease];
	return loginViewController;
}

- (UIViewController *)showNetworkLoginPrefilled:(NSDictionary *)userInfo {
	
	LoginViewController *loginViewController = nil;

	if (userInfo) {
		loginViewController = [[[LoginViewController alloc] initWithTitle: NSLocalizedString(createAccount, @"") 
														 withUserInfoDict: userInfo] autorelease];
		
		NSLog(@"network ID = %@", [userInfo valueForKey:@"networkId"]);
		NSLog(@"username = %@", [userInfo valueForKey:@"username"]);
		NSLog(@"password = %@", [userInfo valueForKey:@"password"]);
		NSLog(@"autoLogin = %@", [userInfo valueForKey:@"autoLogin"]);
	}

	return loginViewController;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CreateNewUserAcctViewController - Create New Account Methods. 
//////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController *)createNewAccount {
	CreateNewUserAcctViewController *createNewUserAcctViewController = [[[CreateNewUserAcctViewController alloc] initWithTitle:NSLocalizedString(createAccount, @"")] autorelease];
	return createNewUserAcctViewController;
}


//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UserAccountMsgViewController - Show the User Account Message Methods. 
//////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController *)allowUserToExploreChannels:(NSString *)title withUserIno:(NSDictionary *)userInfo {
	
	NSLog(@"userinfo : %@", userInfo);
	UserAccountMsgViewController *acctMsgViewController = nil;
	
	if (title && userInfo) {
		acctMsgViewController = [[[UserAccountMsgViewController alloc] initWithTitle:title
																		withUserName:[userInfo valueForKey:@"username"]
																		withPassword:[userInfo valueForKey:@"password"]] autorelease];
	}

	return acctMsgViewController;
}

@end
