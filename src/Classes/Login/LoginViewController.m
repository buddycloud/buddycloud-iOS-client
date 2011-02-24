/* 
 LoginViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "LoginViewController.h"

#define errorMsgView_tag 999

static NSString *loginViewControllerNib = @"LoginViewController";

@implementation LoginViewController

@synthesize networkID, loginTitleLabel, userNameLabel, passwordLabel, loginAutomaticallyLabel, userNameTxtField, passwordTxtField, loginAutomaticallyToggle, loginToolBar;
@synthesize  _prefilledInfoDict;

- (id)initWithTitle:(NSString *)title withUserInfoDict:(NSDictionary *)userInfo {
	if (userInfo && (self = [self initWithTitle:title withNetworkID: [[userInfo valueForKey: @"networkId"] integerValue]])) {
		
		_prefilledInfoDict = [userInfo retain];
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title withNetworkID:(NSInteger)networkId {
	if (self = [super initWithNibName:loginViewControllerNib bundle: [NSBundle mainBundle]]) {
		self.navigationItem.title = NSLocalizedString(buddycloud, @"");
		self.navigationBarTintColor = APPSTYLEVAR(navigationBarColor);
		
		self.networkID = networkId;
		
		[[TTNavigator navigator].URLMap from:kcreateNewAcctURLPath
					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate].atlasUrlHandler selector:@selector(createNewAccount)];
		
		[[TTNavigator navigator].URLMap from:kexploreChannelsURLPath
							toModalViewController:[BuddycloudAppDelegate sharedAppDelegate].atlasUrlHandler selector:@selector(allowUserToExploreChannels:withUserIno:)];

		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(joinBtnLabel, @"")
																				   style:UIBarButtonItemStyleBordered
																				  target:self action:@selector(login:)] autorelease]; 

		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(cancelBtnLabel, @"")
																				   style:UIBarButtonItemStyleBordered
																				  target:self action:@selector(cancel:)] autorelease];
	}
	
	return self;
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:kcreateNewAcctURLPath];
	[[TTNavigator navigator].URLMap removeURL:kexploreChannelsURLPath];
	[_prefilledInfoDict release];
	
	[super dealloc];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.view.backgroundColor = APPSTYLEVAR(appBKgroundColor);
	NSString *network = @"";
	
	switch (networkID) {
		case kloginMethod_network1:
			network = [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), klogin_GmailNetwork];
			break;

		case kloginMethod_network2:
			network = [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), klogin_GmxNetwork];
			break;

		case kloginMethod_network3:
			network = [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), klogin_LiveJournalNetwork];
			break;
		
		case kloginMethod_otherXmppAcct:
			network = [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), klogin_JabberNetwork];
			break;
		
		default:
			break;
	}
	
	self.loginTitleLabel.text = NSLocalizedString(loginMsgTitle, @"");
	self.userNameLabel.text = NSLocalizedString(userName, @"");
	self.passwordLabel.text = NSLocalizedString(password, @"");
	self.loginAutomaticallyLabel.text = NSLocalizedString(loginAutomatically, @"");
	
	self.userNameTxtField.delegate = self;
	if ([_prefilledInfoDict valueForKey: @"username"]) {
		self.userNameTxtField.text = [_prefilledInfoDict valueForKey: @"username"];
	}
	else {
		self.userNameTxtField.text = network;
		self.userNameTxtField.placeholder = (network) ? network : NSLocalizedString(userName, @"");
	}

	self.passwordTxtField.delegate = self;
	if ([_prefilledInfoDict valueForKey: @"password"]) {
		self.passwordTxtField.text = [_prefilledInfoDict valueForKey: @"password"];
	}
	else {
		self.passwordTxtField.placeholder = NSLocalizedString(password, @"");
	}

	self.loginAutomaticallyToggle.on = ([_prefilledInfoDict valueForKey: @"autoLogin"]) ? [[_prefilledInfoDict valueForKey: @"autoLogin"] boolValue] : NO;	//By default NO;
		
	//Username tip
	NSString *userNameTipTxt = [NSString stringWithFormat:@"<p><span class=''>%@</span></p>", NSLocalizedString(userNameTip, @"")];	
	TTStyledTextLabel *userNameTipTxtLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(userNameTxtField.frame.origin.x + 8.0, userNameTxtField.frame.origin.y + userNameTxtField.frame.size.height + 4.0, 189.0, 74.0)] autorelease];
	[userNameTipTxtLabel setBackgroundColor:[UIColor clearColor]];
	[userNameTipTxtLabel setTextColor:RGBCOLOR(6, 58, 70)];
	[userNameTipTxtLabel setHighlightedTextColor:RGBCOLOR(6, 58, 70)];
	[userNameTipTxtLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[userNameTipTxtLabel setText:[TTStyledText textFromXHTML:userNameTipTxt lineBreaks:NO URLs:NO]];
	[userNameTipTxtLabel setUserInteractionEnabled:YES];
	userNameTipTxtLabel.textAlignment = UITextAlignmentLeft;
	[self.view addSubview:userNameTipTxtLabel];
	
	//password tip
	NSString *passwordTipTxt = [NSString stringWithFormat:@"<p><span class=''>%@</span></p>", NSLocalizedString(passwordTip, @"")];
	TTStyledTextLabel *passwordTipTxtLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(passwordTxtField.frame.origin.x + 8.0, passwordTxtField.frame.origin.y + passwordTxtField.frame.size.height + 4.0, 189.0, 74.0)] autorelease];
	[passwordTipTxtLabel setBackgroundColor:[UIColor clearColor]];
	[passwordTipTxtLabel setTextColor:RGBCOLOR(6, 58, 70)];
	[passwordTipTxtLabel setHighlightedTextColor:RGBCOLOR(6, 58, 70)];
	[passwordTipTxtLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[passwordTipTxtLabel setText:[TTStyledText textFromXHTML:passwordTipTxt lineBreaks:NO URLs:NO]];
	[passwordTipTxtLabel setUserInteractionEnabled:YES];
	passwordTipTxtLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:passwordTipTxtLabel];	
	
	if (self.loginToolBar) {
		UIBarButtonItem *createNewAcctBtn = (UIBarButtonItem *)[self.loginToolBar.items objectAtIndex:1];
		createNewAcctBtn.title = NSLocalizedString(createBuddyCloudId, @"");

		UIBarButtonItem *forgetPasswordBtn = (UIBarButtonItem *)[self.loginToolBar.items objectAtIndex:2];
		forgetPasswordBtn.title = NSLocalizedString(forgetPassword, @"");
	}
}

- (void)showErrorMsg:(NSString *)sMsg {
	
	NSString *errorMsg = [NSString stringWithFormat:@"<p><span class=''>%@</span></p>", sMsg];
	TTView *errorView = (TTView *)[[TTNavigator navigator].visibleViewController.view viewWithTag:errorMsgView_tag];
	
	if (errorView == nil) {
		errorView = [[[UIView alloc] initWithFrame:CGRectMake(loginAutomaticallyLabel.frame.origin.x, self.loginAutomaticallyLabel.frame.origin.y + self.loginAutomaticallyLabel.frame.size.height + 5.0, self.view.width - 40.0, 50.0)] autorelease];
		[errorView setBackgroundColor:[UIColor clearColor]];
		[errorView setTag:errorMsgView_tag];
		
		UIImageView *errorImg = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 16.0, 16.0)] autorelease];
		errorImg.image = [UIImage imageNamed:@"error.png"];
		[errorView addSubview:errorImg];
		
		TTStyledTextLabel *errorMsgLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(20.0, 0.0, errorView.frame.size.width, errorView.frame.size.height)] autorelease];
		[errorMsgLabel setBackgroundColor:[UIColor clearColor]];
		[errorMsgLabel setTextColor:[UIColor redColor]];
		[errorMsgLabel setHighlightedTextColor:[UIColor redColor]];
		[errorMsgLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
		[errorMsgLabel setUserInteractionEnabled:YES];
		[errorMsgLabel setTextAlignment:UITextAlignmentLeft];
		[errorMsgLabel setTag:errorLabel_tag];
		[errorView addSubview:errorMsgLabel];	
		
		[self.view addSubview:errorView];
	}
	
	TTStyledTextLabel *errorMsgLabel = (TTStyledTextLabel *)[self.view viewWithTag:errorLabel_tag];
	[errorMsgLabel setText:[TTStyledText textFromXHTML:errorMsg lineBreaks:NO URLs:NO]];
}

- (void)removeErrorMsg {
	TTView *errorView = (TTView *)[self.view viewWithTag:errorMsgView_tag];
	if (errorView) {
		[errorView removeFromSuperview];	//remove the error view.
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark User Authentication Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)login:(id)sender {
	NSLog(@"Login....");
	[self removeErrorMsg];
	
	@try {
		if ([[BuddycloudAppDelegate sharedAppDelegate] isConnectionAvailable])
		{
			//Authenticate the user.
			NSError *error = nil;
			if (![LoginUtility authenticate: &error withUsername: self.userNameTxtField.text withPassword: self.passwordTxtField.text]) {
				
				//Show the error.
				[LoginUtility showError: error];
			}
			else {
				[self.userNameTxtField resignFirstResponder];
				[self.passwordTxtField resignFirstResponder];
				
				//Save the user defaults.
				NSDictionary *userDefaults = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: self.userNameTxtField.text, self.passwordTxtField.text, [[NSNumber numberWithBool:self.loginAutomaticallyToggle.on] stringValue], nil] 
																		 forKeys:[NSArray arrayWithObjects: username_setting, password_setting, autoLogin_setting, nil]]; 
				
				[LoginUtility saveUserDefaultsToSettingBundle:userDefaults];
				
				[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView showActivityLabelInCenter:TTActivityLabelStyleBlackBezel 
																				  withTransparentSheet:YES 
																							  withText:[NSString stringWithFormat:NSLocalizedString(connectingAsJID, @""), self.userNameTxtField.text]];
			}
		}
		else {
			[CustomAlert showAlertMessageWithTitle:NSLocalizedString(alertPrompt, @"") showPreMsg:NSLocalizedString(noInternetConnError, @"")];
		}
	}
	@catch (NSException * e) {
		NSLog(@"Login with new account.. %@", [e description]);
	}
}

- (void)cancel:(id)sender {
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}

- (void)createNewAccount:(id)sender {
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kcreateNewAcctURLPath]];
}

- (void)forgetPassword:(id)sender {
	
	NSLog(@"Forget password....");
}


		 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextFieldDelegate Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.passwordTxtField) {
		
		return YES;
	}
	
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == self.userNameTxtField) {
		[self.passwordTxtField becomeFirstResponder];
	}
	else if (theTextField == self.passwordTxtField) {
		[self login:passwordTxtField];
		return YES;
	}
	
	return NO;
}

@end
