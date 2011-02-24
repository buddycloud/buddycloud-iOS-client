/* 
 UserAccountMsgViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/12/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */
#import "UserAccountMsgViewController.h"


static NSString *userAccountMsgViewControllerNib = @"UserAccountMsgViewController";

@implementation UserAccountMsgViewController

@synthesize successMsgLabel, exploreBtn, _username, _password;

- (id)initWithTitle:(NSString *)title withUserName:(NSString *)username withPassword:(NSString *)password {
	if (self = [super initWithNibName:userAccountMsgViewControllerNib bundle: [NSBundle mainBundle]]) {
		self.navigationItem.title = title;
		self.navigationBarTintColor = APPSTYLEVAR(navigationBarColor);
		self._username = username;
		self._password = password;


	}
	
	return self;
}	

- (void)dealloc {
	
	[super dealloc];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.view.backgroundColor = APPSTYLEVAR(appBKgroundColor);
	self.successMsgLabel.text = NSLocalizedString(registrationSuccess, @"");
	
	NSString *userNameDesc = [NSString stringWithFormat:NSLocalizedString(registrationSuccessDesc, ""), self._username];	
	TTStyledTextLabel *userNameTipTxtLabel = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10.0, self.view.height/2 - 100.0, self.view.width - 15.0, 100.0)] autorelease];
	[userNameTipTxtLabel setBackgroundColor:[UIColor clearColor]];
	[userNameTipTxtLabel setTextColor:RGBCOLOR(6, 58, 70)];
	[userNameTipTxtLabel setHighlightedTextColor:RGBCOLOR(6, 58, 70)];
	[userNameTipTxtLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[userNameTipTxtLabel setText:[TTStyledText textFromXHTML:userNameDesc lineBreaks:NO URLs:NO]];
	[userNameTipTxtLabel setUserInteractionEnabled:YES];
	userNameTipTxtLabel.textAlignment = UITextAlignmentLeft;
	[self.view addSubview:userNameTipTxtLabel];

	[self.exploreBtn setTitle:NSLocalizedString(exploreChannelsBtnLabel, @"") forState:UIControlStateNormal];
}

- (IBAction)exploreBuddyCloud:(id)sender {
	
	XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
	
	@try {
		
		//Reconnect with new username.
		if (xmppEngine && ![xmppEngine.xmppStream isConnected]) {
			
			//Set the JID and password.
			[xmppEngine.xmppStream setHostName:@""];	// Note: The hostname will be resolved through DNS SRV lookup.
			[xmppEngine.xmppStream setMyJID:[XMPPJID jidWithString:self._username resource:XMPP_BC_IPHONE_RESOURCE]];
			xmppEngine.password = self._password;
			
			//Connect the xmpp engine.
			[xmppEngine connect];
		}
			
		[[TTNavigator navigator] removeAllViewControllers];
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kTabBarURLPath]];
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kTabBarItemURLPath, MenuPageBrowse]]];	//land on channel page.
	}
	@catch (NSException * e) {
		NSLog(@"Connecting exception : %@", [e description]);
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


@end
