/* 
 WelcomeViewController.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/30/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "WelcomeViewController.h"

@implementation WelcomeViewController

@synthesize welcomeMsgLabel, exploreBtn, joinBtn;

- (id)initWithNibName:(NSString *)Name {
	if (self = [super initWithNibName:@"WelcomeViewcontroller" bundle: [NSBundle mainBundle]]) {
		self.title = NSLocalizedString(welcome, @"");
	}
		
	return self;
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
	
	[[TTNavigator navigator] removeAllViewControllers];
	
	[[TTNavigator navigator].URLMap from:kPostWithNodeAndTitleURLPath toViewController:[PostsViewController class]];
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kTabBarURLPath]];
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:kTabBarItemURLPath, MenuPageChannel]]];	//land on channel page.
}


- (IBAction)joinBuddyCloud:(id)sender {
	
	NSLog(@"join buddy cloud....");
}


@end
