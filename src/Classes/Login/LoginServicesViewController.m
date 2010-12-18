/* 
 LoginServicesViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "LoginServicesViewController.h"

static NSString *loginServicesViewControllerNib = @"LoginServicesViewController";

@implementation LoginServicesViewController

@synthesize loginServiceTitleLabel, networkBtn1, networkBtn2, networkBtn3, otheXmppAcctBtn, createNewAcctBtn;

- (id)initWithTitle:(NSString *)title {
	if (self = [super initWithNibName:loginServicesViewControllerNib bundle: [NSBundle mainBundle]]) {
		self.title = NSLocalizedString(buddycloud, @"");
		
		[[TTNavigator navigator].URLMap from:kloginURLPath
					   toModalViewController:self selector:@selector(showNetworkLogin:)];

		[[TTNavigator navigator].URLMap from:kcreateNewAcctURLPath
					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate] selector:@selector(createNewAccount)];
	}
	
	return self;
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:kloginURLPath];
	[[TTNavigator navigator].URLMap removeURL:kcreateNewAcctURLPath];
	
	[super dealloc];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.loginServiceTitleLabel.text = NSLocalizedString(loginServicesListTitle, @"");
	
	[self.networkBtn1 setTitle:NSLocalizedString(network1Label, @"") forState:UIControlStateNormal];
	[self.networkBtn1 setTag:kloginMethod_network1];
	
	[self.networkBtn2 setTitle:NSLocalizedString(network2Label, @"") forState:UIControlStateNormal];
	[self.networkBtn2 setTag:kloginMethod_network2];
	
	[self.networkBtn3 setTitle:NSLocalizedString(network3Label, @"") forState:UIControlStateNormal];
	[self.networkBtn3 setTag:kloginMethod_network3];
	
	[self.otheXmppAcctBtn setTitle:NSLocalizedString(otherXmppAcctBtnLabel, @"") forState:UIControlStateNormal];
	[self.otheXmppAcctBtn setTag:kloginMethod_otherXmppAcct];
	
	[self.createNewAcctBtn setTitle:NSLocalizedString(createNewAcctBtnLabel, @"") forState:UIControlStateNormal];
	[self.createNewAcctBtn setTag:kloginMethod_createNewAcct];
}

- (IBAction)openScreen:(id)sender {
	
	UIButton *clickedBtn = (UIButton *)sender;
	NSLog(@"Tag : %d", clickedBtn.tag);
	
	if (clickedBtn.tag == kloginMethod_createNewAcct) {
		//Create new account screen.
		NSLog(@"Create new account screen.");
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kcreateNewAcctURLPath]];
	}
	else {
		//Open specific network login screen.
		NSLog(@"Open specific network login screen.");
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kloginWithNetworkIDURLPath, clickedBtn.tag]]];
	}
}

- (UIViewController *)showNetworkLogin:(NSInteger)networkId {
	LoginViewController *loginViewController = [[[LoginViewController alloc] initWithTitle:NSLocalizedString(createAccount, @"")
																			 withNetworkID:networkId] autorelease];
	return loginViewController;
}

@end
