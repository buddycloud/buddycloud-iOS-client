/* 
 LoginUtility.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 1/5/11.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "LoginUtility.h"

NSString *const LoginUtilityErrorDomain = @"LoginUtilityErrorDomain";
static BOOL _autoLogin = NO;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface LoginUtility (PrivateAPI)

+ (void)registerDefaultsFromSettingsBundle;
+ (void)userDidAuthenticate:(NSNotification *)notification;
+ (void)userDidNotAuthenticate:(NSNotification *)notification;
+ (void)registeredWithSuccess:(NSNotification *)notification;
+ (void)registeredWithFailure:(NSNotification *)notification;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation LoginUtility

+ (BOOL)performAutoLogin {
	
	if ([[BuddycloudAppDelegate sharedAppDelegate] isConnectionAvailable])
	{
		[[NSNotificationCenter defaultCenter] addObserver: [LoginUtility class]
												 selector: @selector(userDidAuthenticate:)
													 name: [Events USER_LOGGED_IN_SUCCESS]
												   object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: [LoginUtility class]
												 selector: @selector(userDidNotAuthenticate:)
													 name: [Events USER_LOGGED_IN_FAILED]
												   object: nil];
		
		NSString *userNameValue = [[NSUserDefaults standardUserDefaults] stringForKey: username_setting];
		NSString *passwordValue = [[NSUserDefaults standardUserDefaults] stringForKey: password_setting];
		NSString *autoLoginValue = [[NSUserDefaults standardUserDefaults] stringForKey: autoLogin_setting];
		
		NSLog(@"### Before >> userName before is %@", userNameValue);
		NSLog(@"### Before >> password before is %@", passwordValue);
		NSLog(@"### Before >> autoLoginValue before is %@ and [autoLoginValue boolValue] : %@", autoLoginValue, ([autoLoginValue boolValue]) ? @"YES" : @"NO");
		
		//If don't have any values, reset with the default settings.
		if (autoLoginValue == nil)
			[self registerDefaultsFromSettingsBundle];
		
		_autoLogin = [autoLoginValue boolValue];

		//Auto authenticate.
		if (_autoLogin) {
			
			NSError *error = nil;
			if (![LoginUtility authenticate: &error withUsername: userNameValue withPassword: passwordValue]) {
				
				//If the user name is not valid, or any other then show the login page with prefilled contents.
				if ([error code] == kloginWarn_userNameNotValid) {
					NSLog(@"Auto login.....!!!");
					
					[LoginUtility showError: error];
					return YES;
				}
			}
		}
	}
	else {
		[CustomAlert showAlertMessageWithTitle:NSLocalizedString(alertPrompt, @"") showPreMsg:NSLocalizedString(noInternetConnError, @"")];
	}
	
	return NO;
}

+ (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
		if(key) {
			id defaultValue = ([key isEqualToString: autoLogin_setting]) ? [[NSNumber numberWithBool:NO] stringValue] : [prefSpecification objectForKey:@"DefaultValue"];
			[defaultsToRegister setObject:defaultValue forKey:key];
			
			//NSLog(@"Default Key = %@ , Value = %@", key, defaultValue);
        }
    }
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

+ (void)saveUserDefaultsToSettingBundle:(NSDictionary *)userDefaults {
	
	if (userDefaults) {

		// Set the application defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:[userDefaults valueForKey:username_setting] forKey:@"username_setting"];
		[defaults setValue:[userDefaults valueForKey:password_setting] forKey:@"password_setting"];
		[defaults setBool: [[userDefaults valueForKey:autoLogin_setting] boolValue] forKey:@"autoLogin_setting"];

		[defaults synchronize];
	}
}

+ (void)showError:(NSError *)error {
	
	CustomAlert *alertView = nil;
	NSString *alertTitle = NSLocalizedString(alertPrompt, @"");
	NSString *errorMsg = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
	id viewController = [TTNavigator navigator].visibleViewController;
	
	//NOTE: In the background anonymoues login, if some error occured we have to notify user on the login screen.
	if (_autoLogin && [error userInfo]) {
		
		[[TTNavigator navigator].URLMap from:kloginPrefilledURLPath
					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate].atlasUrlHandler selector:@selector(showNetworkLoginPrefilled:)];
		
		NSString *kloginPrefilledWithNetwork = [NSString stringWithFormat:kloginPrefilledWithNetworkIDURLPath, kloginMethod_otherXmppAcct, [[error userInfo] valueForKey: usernameKey], [[error userInfo] valueForKey: passwordKey], [[NSNumber numberWithBool:_autoLogin] stringValue]];
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath: kloginPrefilledWithNetwork]];
	
		//Once it's failed, then it's manual operation.
		_autoLogin = NO;
	}
	
	
	if ([viewController isKindOfClass: [LoginViewController class]]) {
		LoginViewController *loginViewController = (LoginViewController *)viewController;
		
		//Show the error tip on login page.
		[loginViewController showErrorMsg:errorMsg];
	}
	else if ([viewController isKindOfClass: [CreateNewUserAcctViewController class]]) {
		CreateNewUserAcctViewController *newUserAcctViewController = (CreateNewUserAcctViewController *)viewController;
		
		//Show the error tip on create new user acct page.
		[newUserAcctViewController showErrorMsg:errorMsg];
	}
	
	alertView = [[[CustomAlert alloc] initWithTitle:alertTitle
											message:errorMsg
										   delegate:self 
								  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
								  otherButtonTitles:nil] autorelease];
	[alertView show];
	
	//Stop the error message activity.
	[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Authentication 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)authenticate:(NSError **)errPtr 
		withUsername:(NSString *)sUsername 
		withPassword:(NSString *)sPassword
{	
	if ((sUsername && ![sUsername isEmptyOrWhitespace]) &&
		(sPassword && ![sPassword isEmptyOrWhitespace]))
	{
		XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
		NSRange range = [sUsername rangeOfString:@"@" options:NSLiteralSearch];
		
		if(range.location != NSNotFound && range.length > 0) {
		
			//Disconnect the xmpp engine if it's connected.
			if ([xmppEngine.xmppStream isConnected]) {
				[xmppEngine disconnect];
			}
		
			//Set the JID and password.
			[xmppEngine.xmppStream setHostName:@""];	// Note: The hostname will be resolved through DNS SRV lookup.
			[xmppEngine.xmppStream setMyJID:[XMPPJID jidWithString: sUsername resource: XMPP_BC_IPHONE_RESOURCE]];
			xmppEngine.password = sPassword;
			
			//Connect the xmpp engine.
			[xmppEngine connect];
		}
		else if (errPtr)
		{
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(usernameIsNotValid, @""), sUsername];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:sUsername, sPassword, errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];

			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_userNameNotValid userInfo:info];
			return NO;
		}
	}
	else if (errPtr) {

		if (!sUsername || [sUsername isEmptyOrWhitespace]) {
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(userName, @"")];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(userName, @""), NSLocalizedString(password, @""), errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
			
			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_userNameEmpty userInfo:info];
			
			return NO;
		}
		else if (!sPassword || [sPassword isEmptyOrWhitespace]) {
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(password, @"")];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(userName, @""), NSLocalizedString(password, @""), errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
			
			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_passwordEmpty userInfo:info];
			
			return NO;
		}
	}

	return YES;
}

/*
 * User Authentication Success.
 */
+ (void)userDidAuthenticate:(NSNotification *)notification {
	@try {
		if (_autoLogin) {
			
			//Background Authentication, Show the Explore/Browse page.
			[[TTNavigator navigator] removeAllViewControllers];
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kTabBarURLPath]];
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kTabBarItemURLPath, MenuPageBrowse]]];	//land on channel page.
		}
		else {
			//Explicit Authentication, Show the User Account Message page.
			[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
		
			XMPPEngine *xmppEngine = [[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
			if (xmppEngine) {
				[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kexploreChannelsWithTitleAndUsernameURLPath,
																				   NSLocalizedString(buddycloud, @""), [[xmppEngine.xmppStream myJID] bare], xmppEngine.password]]];	
			}
		}
	}
	@catch (NSException * e) {
		NSLog(@"userDidAuthenticate .. %@", [e description]);
	}
}

/*
 * User Authentication Failed.
 */
+ (void)userDidNotAuthenticate:(NSNotification *)notification {
	
	NSLog(@"--------------------userDidNotAuthenticate:--------------------");
	NSError *error = (NSError *)[notification object];
	[LoginUtility showError: error];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Registration 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)registerNewUser:(NSError **)errPtr 
		   withUsername:(NSString *)sUsername 
		   withPassword:(NSString *)sPassword
{
	if ((sUsername && ![sUsername isEmptyOrWhitespace]) &&
		(sPassword && ![sPassword isEmptyOrWhitespace]))
	{
		XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
		NSRange range = [sUsername rangeOfString:@"@buddycloud.com" options:NSLiteralSearch];
	
		if(range.location != NSNotFound && range.length > 0) {
		
			//Disconnect the xmpp engine if it's connected.
			if ([xmppEngine.xmppStream isConnected]) {
				[xmppEngine disconnect];
			}
		
			//Set the JID and password.
			[xmppEngine.xmppStream setHostName:@""];	// Note: The hostname will be resolved through DNS SRV lookup.
			[xmppEngine.xmppStream setMyJID:[XMPPJID jidWithString: sUsername resource: XMPP_BC_IPHONE_RESOURCE]];
			xmppEngine.password = sPassword;
			xmppEngine.isNewUserRegisteration = YES;
		
			//Connect the xmpp engine.
			[xmppEngine connect];
		}	
		else if (errPtr)
		{
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(usernameIsNotValid, @""), sUsername];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:sUsername, sPassword, errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
			
			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_userNameNotValid userInfo:info];
			return NO;
		}
	}
	else if (errPtr) {
		
		if (!sUsername || [sUsername isEmptyOrWhitespace]) {
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(userName, @"")];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(userName, @""), NSLocalizedString(password, @""), errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
			
			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_userNameEmpty userInfo:info];
			
			return NO;
		}
		else if (!sPassword || [sPassword isEmptyOrWhitespace]) {
			NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(password, @"")];
			NSDictionary *info = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(userName, @""), NSLocalizedString(password, @""), errMsg, nil]  
															 forKeys: [NSArray arrayWithObjects:usernameKey, passwordKey, NSLocalizedDescriptionKey, nil]];
			
			*errPtr = [NSError errorWithDomain:LoginUtilityErrorDomain code:kloginWarn_passwordEmpty userInfo:info];
			
			return NO;
		}
	}
	
	return YES;
}

/*
 * User Registration Success.
 */
+ (void)registeredWithSuccess:(NSNotification *)notification {
	XMPPEngine *xmppEngine = [[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
	
	@try {
		if (xmppEngine) {
			[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kexploreChannelsWithTitleAndUsernameURLPath,
																				   NSLocalizedString(buddycloud, @""), [[xmppEngine.xmppStream myJID] bare], xmppEngine.password]]];	
		}
		
		[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
	}
	@catch (NSException * e) {
		NSLog(@"registeredWithSuccess .. %@", [e description]);
	}	
}

/*
 * User Registration Failed.
 */
+ (void)registeredWithFailure:(NSNotification *)notification {
	
	NSLog(@"--------------------registeredWithFailure:--------------------");
	
	NSError *error = (NSError *)[notification object];
	[LoginUtility showError: error];
}

@end
