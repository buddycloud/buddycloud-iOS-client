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

- (id)initWithTitle:(NSString *)title withNetworkID:(NSInteger)networkId {
	if (self = [super initWithNibName:loginViewControllerNib bundle: [NSBundle mainBundle]]) {
		self.title = NSLocalizedString(buddycloud, @"");
		self.networkID = networkId;
		
		[[TTNavigator navigator].URLMap from:kcreateNewAcctURLPath
					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate] selector:@selector(createNewAccount)];
		
		[[TTNavigator navigator].URLMap from:kexploreChannelsURLPath
							toModalViewController:self selector:@selector(allowUserToExploreChannels:withUserIno:)];

		
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
	
	[super dealloc];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
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
	
	self.userNameTxtField.text = network;
	self.userNameTxtField.placeholder = (network) ? network : NSLocalizedString(userName, @"");
	self.userNameTxtField.delegate = self;
	self.passwordTxtField.placeholder = NSLocalizedString(password, @"");
	self.passwordTxtField.delegate = self;
	self.loginAutomaticallyToggle.on = NO;	//By default NO;
		
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
	TTView *errorView = (TTView *)[self.view viewWithTag:errorMsgView_tag];
	
	if (errorView == nil) {
		errorView = [[[UIView alloc] initWithFrame:CGRectMake(self.loginAutomaticallyLabel.frame.origin.x, self.loginAutomaticallyLabel.frame.origin.y + self.loginAutomaticallyLabel.frame.size.height + 5.0, self.view.width - 40.0, 50.0)] autorelease];
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
	UIAlertView *alertView = nil;
	
	@try {
		if ( [[BuddycloudAppDelegate sharedAppDelegate] isConnectionAvailable] && (self.userNameTxtField.text != nil && ![self.userNameTxtField.text isEmptyOrWhitespace]) &&
			(self.passwordTxtField.text != nil && ![self.passwordTxtField.text isEmptyOrWhitespace]) )
		{
			[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView showActivityLabelInCenter:TTActivityLabelStyleBlackBezel 
																			  withTransparentSheet:YES 
																						  withText:[NSString stringWithFormat:NSLocalizedString(connectingAsJID, @""), self.userNameTxtField.text]];
			
			[[NSNotificationCenter defaultCenter] addObserver: self
													 selector: @selector(userDidAuthenticate:)
														 name: [Events USER_LOGGED_IN_SUCCESS]
													   object: nil];
			
			[[NSNotificationCenter defaultCenter] addObserver: self
													 selector: @selector(userDidNotAuthenticate:)
														 name: [Events USER_LOGGED_IN_FAILED]
													   object: nil];
			
			XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
			NSRange range = [self.userNameTxtField.text rangeOfString:@"@" options:NSLiteralSearch];
			
			//Before disconnect, check if it's not the same username through which it's already login.
			if(range.location != NSNotFound && range.length > 0) {
//				
//				if ([[xmppEngine.xmppStream.myJID bare] isEqualToString:self.userNameTxtField.text]) {
//					
//					
//					
//					//Stop the activity.
//					[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
//					
//					alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(alertPrompt, @"")
//															message:[NSString stringWithFormat:NSLocalizedString(userNameLoggedInConflictError, @""), NSLocalizedString(userName, @"")]
//														   delegate:self
//												  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
//												  otherButtonTitles:nil] autorelease];
//					[alertView show];
//					
//					return;
//				}
				
				[self.userNameTxtField resignFirstResponder];
				[self.passwordTxtField resignFirstResponder];
				
				//Disconnect the xmpp engine if it's connected.
				if ([xmppEngine.xmppStream isConnected]) {
					[xmppEngine disconnect];
				}
				
				//Set the JID and password.
				[xmppEngine.xmppStream setHostName:@""];	// Note: The hostname will be resolved through DNS SRV lookup.
				[xmppEngine.xmppStream setMyJID:[XMPPJID jidWithString:self.userNameTxtField.text resource:XMPP_BC_IPHONE_RESOURCE]];
				xmppEngine.password = self.passwordTxtField.text;
				
				//Connect the xmpp engine.
				[xmppEngine connect];
			}
			else {
				//Stop the activity.
				[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
				
				alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(alertPrompt, @"")
														message:[NSString stringWithFormat:NSLocalizedString(usernameIsNotValid, @""), self.userNameTxtField.text]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
											  otherButtonTitles:nil] autorelease];
				[alertView show];
			}
		}
		else {
			if ([self.userNameTxtField.text isEmptyOrWhitespace]) {
				alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(alertPrompt, @"")
														message:[NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(userName, @"")]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
											  otherButtonTitles:nil] autorelease];
				[alertView show];
			}
			else if ([self.passwordTxtField.text isEmptyOrWhitespace]) {
				alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(alertPrompt, @"")
														message:[NSString stringWithFormat:NSLocalizedString(wilcardCanNotBeEmpty, @""), NSLocalizedString(password, @"")]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
											  otherButtonTitles:nil] autorelease];
				[alertView show];
				[alertView show];
			}
			else {
				[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView showActivityTimerLabelInCenter:TTActivityLabelStyleBlackBox withText:NSLocalizedString(noInternetConnError, @"")];
			}
		}
	}
	@catch (NSException * e) {
		NSLog(@"Login with new account.. %@", [e description]);
	}
}

- (void)userDidAuthenticate:(NSNotification *)notification {
	@try {
		[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
		
		XMPPEngine *xmppEngine = [[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
		if (xmppEngine) {
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kexploreChannelsWithTitleAndUsernameURLPath,
																				   NSLocalizedString(buddycloud, @""), [[xmppEngine.xmppStream myJID] full], @""]]];	
		}
	}
	@catch (NSException * e) {
		NSLog(@"userDidAuthenticate .. %@", [e description]);
	}
}

- (void)userDidNotAuthenticate:(NSNotification *)notification {

	UIAlertView *alertView = nil;
	NSInteger errorCode = kreg_unknwonError;
	
	if ([[notification object] class] == [NSError class]) {
		NSError *error = (NSError *)[notification object];
		errorCode = [error code];
	}
	else {
		errorCode = [[notification object] integerValue];
	}
	
	if (errorCode == kreg_userAuthenticationError) {
		NSLog(@"Username kreg_userAuthenticationError....");
		[self showErrorMsg:NSLocalizedString(authenticatonFailedError, @"")];
		
		alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(authenticationFailed, @"")
												message:[NSString stringWithFormat: NSLocalizedString(authenticatonFailedError, @""), self.userNameTxtField.text]
											   delegate:self 
									  cancelButtonTitle:NSLocalizedString(okButtonLabel, @"") 
									  otherButtonTitles:nil] autorelease];
		[alertView show];
	}
	
	[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView stopActivity];
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

- (UIViewController *)allowUserToExploreChannels:(NSString *)title withUserIno:(NSDictionary *)userInfo {
	
	NSLog(@"userinfo : %@", userInfo);
	
	UserAccountMsgViewController *acctMsgViewController = [[[UserAccountMsgViewController alloc] initWithTitle:title 
																								  withUserName:[userInfo valueForKey:@"username"]
																								  withPassword:[userInfo valueForKey:@"password"]] autorelease];
	
	return acctMsgViewController;
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
