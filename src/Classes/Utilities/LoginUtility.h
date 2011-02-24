/* 
 LoginUtility.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 1/5/11.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "XMPPEngine.h"

// Setting bundle keys
#define username_setting	@"username_setting"
#define password_setting	@"password_setting"
#define autoLogin_setting	@"autoLogin_setting"

extern NSString *const LoginUtilityErrorDomain;

typedef enum {
	kloginWarn_None = 0,
	kloginWarn_userNameNotValid,
	kloginWarn_userNameEmpty,
	kloginWarn_passwordEmpty,
} LoginWarnings;

@class XMPPEngine;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface LoginUtility : NSObject {
	
}

+ (BOOL)performAutoLogin;
+ (void)saveUserDefaultsToSettingBundle:(NSDictionary *)userDefaults;

+ (void)showError:(NSError *)error;

+ (BOOL)authenticate:(NSError **)errPtr 
		withUsername:(NSString *)sUsername 
		withPassword:(NSString *)sPassword;

+ (BOOL)registerNewUser:(NSError **)errPtr 
		   withUsername:(NSString *)sUsername 
		   withPassword:(NSString *)sPassword;
@end
