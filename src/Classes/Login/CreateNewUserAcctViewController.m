/* 
 CreateNewUserAcctViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */
 
#import "CreateNewUserAcctViewController.h"

static NSString *createNewUserAcctViewController = @"CreateNewUserAcctViewController";

@implementation CreateNewUserAcctViewController

@synthesize createTitleLabel, registerTitleLabel, userNameLabel, newPasswordLabel, userNameTxtField, newPasswordTxtField, helpBtn;

- (id)initWithTitle:(NSString *)title {
	if (self = [super initWithNibName:createNewUserAcctViewController bundle: [NSBundle mainBundle]]) {
		
		self.navigationItem.title = title;
		self.navigationBarTintColor = APPSTYLEVAR(navigationBarColor);
		
		[[NSNotificationCenter defaultCenter] addObserver: [LoginUtility class]
												 selector: @selector(registeredWithSuccess:)
													 name: [Events USER_REGISTRATION_SUCCESS]
												   object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: [LoginUtility class]
												 selector: @selector(registeredWithFailure:)
													 name: [Events USER_REGISTRATION_FAILED]
												   object: nil];
		
		[[TTNavigator navigator].URLMap from:kexploreChannelsURLPath
							toModalViewController:[BuddycloudAppDelegate sharedAppDelegate].atlasUrlHandler selector:@selector(allowUserToExploreChannels:withUserIno:)];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(joinBtnLabel, @"") 
																				   style:UIBarButtonItemStyleBordered
																				  target:self action:@selector(join:)] autorelease]; 
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(cancelBtnLabel, @"") 
																				  style:UIBarButtonItemStyleBordered
																				 target:self action:@selector(cancel:)] autorelease];
	}
	
	return self;
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:kexploreChannelsURLPath];
	
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [self.userNameTxtField becomeFirstResponder];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.view.backgroundColor = APPSTYLEVAR(appBKgroundColor);
	self.createTitleLabel.text = NSLocalizedString(createBuddyCloudId, @"");
	self.registerTitleLabel.text = NSLocalizedString(registerAcctMsg, @"");
	self.userNameLabel.text = [NSString stringWithFormat:NSLocalizedString(chooseAWildCard, @""), NSLocalizedString(userName, @"")];
	self.newPasswordLabel.text = [NSString stringWithFormat:NSLocalizedString(chooseAWildCard, @""), NSLocalizedString(password, @"")];

	self.userNameTxtField.text =  [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), @"buddycloud.com"];
	self.userNameTxtField.placeholder =  [NSString stringWithFormat:NSLocalizedString(jidWithNetwork, @""), @"buddycloud.com"];
	self.userNameTxtField.delegate = self;
	
	self.newPasswordTxtField.placeholder = NSLocalizedString(password, @"");
	self.newPasswordTxtField.delegate = self;
}

- (void)showErrorMsg:(NSString *)sMsg {
	
	NSString *errorMsg = [NSString stringWithFormat:@"<p><span class=''>%@</span></p>", sMsg];
	TTView *errorView = (TTView *)[self.view viewWithTag:errorMsgView_tag];
	
	if (errorView == nil) {
		errorView = [[[UIView alloc] initWithFrame:CGRectMake(self.newPasswordLabel.frame.origin.x, self.newPasswordLabel.frame.origin.y + self.newPasswordLabel.frame.size.height + 5.0, self.view.width - 20.0, 50.0)] autorelease];
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

- (void)join:(id)sender {
	NSLog(@"join.....");
	[self removeErrorMsg];
	
	if ([[BuddycloudAppDelegate sharedAppDelegate] isConnectionAvailable])
	{
		[[BuddycloudAppDelegate sharedAppDelegate].spiralLoadingView showActivityLabelWithStyle:TTActivityLabelStyleBlackBezel 
																					   withText:NSLocalizedString(loading, @"")
																		   withTransparentSheet:YES
																			  withActivityFrame:CGRectMake(self.view.width/2 - 50.0, self.view.height/2 - (100.0 + 30.0), 100.0, 100.0)]; 
		//Register the new user.
		NSError *error = nil;
		if (![LoginUtility registerNewUser: &error withUsername: self.userNameTxtField.text withPassword: self.newPasswordTxtField.text]) {
			
			//Show the error.
			[LoginUtility showError: error];
		}
	}
	else {
		[CustomAlert showAlertMessageWithTitle:NSLocalizedString(alertPrompt, @"") showPreMsg:NSLocalizedString(noInternetConnError, @"")];
	}
}

- (void)cancel:(id)sender {
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextFieldDelegate Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == self.userNameTxtField) {
		[self.newPasswordTxtField becomeFirstResponder];
	}
	else if (theTextField == self.newPasswordTxtField) {
		[self join:newPasswordTxtField];
		return YES;
	}
	
	return NO;
}

@end
