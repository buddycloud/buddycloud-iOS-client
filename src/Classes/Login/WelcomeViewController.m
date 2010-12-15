/* 
 WelcomeViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/30/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "WelcomeViewController.h"

static NSString *welcomeViewControllerNib = @"WelcomeViewcontroller";

@implementation WelcomeViewController

@synthesize welcomeMsgLabel, exploreBtn, joinBtn;

- (id)initWithNibName:(NSString *)Name {
	if (self = [super initWithNibName:welcomeViewControllerNib bundle:[NSBundle mainBundle]]) {
		self.title = NSLocalizedString(welcome, @"");
		
		[[TTNavigator navigator].URLMap from:kloginServicesWithTitleURLPath toViewController:[LoginServicesViewController class]];
		[[TTNavigator navigator].URLMap from:kPostWithNodeAndTitleURLPath toViewController:[PostsViewController class]];
	}
		
	return self;
}

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:kloginServicesWithTitleURLPath];
	[[TTNavigator navigator].URLMap removeURL:kPostWithNodeAndTitleURLPath];
	
	[super dealloc];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.welcomeMsgLabel.text = NSLocalizedString(welcomeMsg, @"");
	[self.exploreBtn setTitle:NSLocalizedString(exploreBtnLabel, @"") forState:UIControlStateNormal];
	[self.joinBtn setTitle:NSLocalizedString(joinBtnLabel, @"") forState:UIControlStateNormal];
	
	youTubeView = [[TTYouTubeView alloc] initWithURLPath:appIntroVedioUrl];
	youTubeView.width = 230;
	youTubeView.height = 150;
	youTubeView.mediaPlaybackRequiresUserAction = YES;
	youTubeView.center = CGPointMake(self.view.width/2, 180);
	youTubeView.backgroundColor = RGBCOLOR(6, 58, 70);
	[self.view addSubview:youTubeView];
}

- (IBAction)exploreBuddyCloud:(id)sender {
	
	@try {
		XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];

		// Start default anonyomous connection
		[xmppEngine connect];
		
		[[TTNavigator navigator] removeAllViewControllers];
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kTabBarURLPath]];
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kTabBarItemURLPath, MenuPageChannel]]];	//land on channel page.
	}
	@catch (NSException * e) {
		NSLog(@"Exception : %@", [e description]);
	}
}


- (IBAction)joinBuddyCloud:(id)sender {
	
	NSLog(@"join buddy cloud....");
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kloginServicesWithTitleURLPath]];	//land on login services page.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
	//TTIsSupportedOrientation(interfaceOrientation);
}


@end
