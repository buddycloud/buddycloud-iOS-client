/* 
 WelcomeViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/30/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "TabBarController.h"
#import "XMPPEngine.h"
#import "XMPPInBandReg.h"
#import "LoginServicesViewController.h"

@interface WelcomeViewController : TTViewController {

	UILabel *welcomeMsgLabel;
	UIButton *exploreBtn;
	UIButton *joinBtn;
	
	TTYouTubeView *youTubeView;
}

@property (nonatomic, retain) IBOutlet UILabel *welcomeMsgLabel; 
@property (nonatomic, retain) IBOutlet UIButton *exploreBtn; 
@property (nonatomic, retain) IBOutlet UIButton *joinBtn; 

- (IBAction)exploreBuddyCloud:(id)sender;
- (IBAction)joinBuddyCloud:(id)sender;


@end
