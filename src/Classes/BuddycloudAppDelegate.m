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
#import "Util.h"

@implementation BuddycloudAppDelegate
@synthesize window;
@synthesize followingTableView, postsTableView;
@synthesize followingController, settingsController;
@synthesize spiralLoadingView;

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
	[xmppEngine setPassword: XMPP_ANONYMOUS_DEFAULT_JID];

	placeEngine = [[PlaceEngine alloc] initWithStream: [xmppEngine xmppStream] toServer: PLACE_ENGINE_SERVER];
	
	//Start the reachibility.
	[self checkF2FReachability];
	
	//Auto Login
	//[self autoLogin];
	
	//Initialize the UI Settings.
	[self initializeUI];
	
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//[self autoLogin];
}

- (void)initializeUI {
	
	@try {
		TTDefaultCSSStyleSheet* styleSheet = [[TTDefaultCSSStyleSheet alloc] init];
		[styleSheet addStyleSheetFromDisk:TTPathForBundleResource(@"stylesheet.css")];
		[TTStyleSheet setGlobalStyleSheet:styleSheet];
		TT_RELEASE_SAFELY(styleSheet);
		
		spiralLoadingView = [[SpiralLoadingView alloc] init];
		
		//Load all the mapping urls.
		[self loadAllMappedUrls];
		
		// Before opening the tab bar, we see if the controller history was persisted the last time
		if ([[TTNavigator navigator] restoreViewControllers]) {
			[[TTNavigator navigator] removeAllViewControllers];
		}
		
		// This is the first launch, so we just start with the tab bar
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kAppRootURLPath]];
	}
	@catch (NSException * e) {
		NSLog(@"Exception : %@", [e description]);
	}
}

/*
 * Load all the url map.
 */
- (void)loadAllMappedUrls {
	
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
	navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
	
	TTURLMap* map = navigator.URLMap;
	
	// Any URL that doesn't match will fall back on this one, and open in the web browser
	[map from:@"*" toViewController:[TTWebController class]];
	
	// Application welcome screen
	[map from:kAppRootURLPath toSharedViewController:[WelcomeViewController class]];
	
	// The tab bar controller is shared, meaning there will only ever be one created.  Loading
	// This URL will make the existing tab bar controller appear if it was not visible.
	[map from:kTabBarURLPath toModalViewController:[TabBarController class]];
	
	// Check the post against node.
	[map from:kPostURLPath toViewController:[PostsViewController class]];
}

/*
- (void)autoLogin {
	
	NSString *userNameValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"username_setting"];
//	NSString *passwordValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"password_setting"];
//	NSString *domainValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"host_setting"];
//	NSString *autoLoginValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"autoLogin_setting"];

    NSLog(@"name before is %@", userNameValue);
	
    // Note: this will not work for boolean values as noted by bpapa below.
    // If you use booleans, you should use objectForKey above and check for null
    if(!userNameValue) {
        [self registerDefaultsFromSettingsBundle];
        userNameValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"username_setting"];
    }
    NSLog(@"name after is %@", userNameValue);
	
	//[NSUserDefaults standardUserDefaults] 
	
//	NSLog(@"Username : %@", userNameValue);
//	NSLog(@"Password : %@", passwordValue);
//	NSLog(@"Domain Value : %@", domainValue);
//	NSLog(@"Login auto : %@", autoLoginValue);
}

- (void)registerDefaultsFromSettingsBundle {
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
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

*/

- (void)dealloc
{
	[window release];
	[spiralLoadingView release];
	
	[internetReach release];
	
	[super dealloc];
}


- (UIViewController *)createNewAccount {
	CreateNewUserAcctViewController *createNewUserAcctViewController = [[[CreateNewUserAcctViewController alloc] initWithTitle:NSLocalizedString(createAccount, @"")] autorelease];
	return createNewUserAcctViewController;
}


/*
 * Shared App Delegate.
 */
+ (BuddycloudAppDelegate *)sharedAppDelegate {

	return (BuddycloudAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (XMPPEngine *)xmppEngine
{
	return xmppEngine;
}

- (FollowingDataModel *)followingDataModel
{
	return xmppEngine;
}



#pragma mark - APP WIFI/EDGE/GPRS/XMPP-Stream REACHIBILITY CHECK
/* 
 * Check Server Reachability.
 */
- (void) checkF2FReachability {
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifer];
	[self updateReachability: internetReach];
}

/*
 * Called by Reachability whenever status changes.  
 */
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateReachability:curReach];
	
	if (!isInternetConAvailable){	
		[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView showActivityTimerLabelInCenter:TTActivityLabelStyleBlackBox withText:NSLocalizedString(noInternetConnError, @"")];
	}
}

/*
 * Update the connection flags asap reachibility changes.  
 */
- (void) updateReachability:(Reachability *)curReach {
	
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	BOOL connectionRequired = [curReach connectionRequired];
	
	if (curReach == internetReach) {
		if (netStatus == ReachableViaWiFi && connectionRequired == NO)
		{
			isInternetConAvailable = YES;
		}
		else if (netStatus == ReachableViaWWAN && connectionRequired == NO)
		{
			isInternetConAvailable = YES;
		}
		else if (((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN)) && connectionRequired == YES)
		{
			TTNetworkRequestStarted();
			isInternetConAvailable = ([[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kReachibility_ping_uri] 
																								cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0] delegate:self]) ? YES : NO;
			
			isInternetConAvailable = YES;
			
			TTNetworkRequestStopped();
		}
		else if ([xmppEngine.xmppStream isConnected]) {
			isInternetConAvailable = YES;
		}
		else
		{
			isInternetConAvailable = NO;
		}
	}
}

/*
 * Checks Reachability of Host Server.
 */
-(BOOL)isConnectionAvailable {
	
	if(isInternetConAvailable)
		return YES;
	else
		return NO;
}

@end
