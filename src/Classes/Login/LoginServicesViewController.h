/* 
 LoginServicesViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "XMPPEngine.h"

typedef enum {
	kloginMethod_createNewAcct	= 0,

	kloginMethod_network1		= 1,
	kloginMethod_network2		= 2,
	kloginMethod_network3		= 3,
	kloginMethod_otherXmppAcct	= 4,	
} LoginMethods;

@interface LoginServicesViewController : TTViewController {
	
	UILabel *loginServiceTitleLabel;
	UIButton *networkBtn1;
	UIButton *networkBtn2;
	UIButton *networkBtn3;
	UIButton *otheXmppAcctBtn;
	UIButton *createNewAcctBtn;
}

@property (nonatomic, retain) IBOutlet UILabel *loginServiceTitleLabel; 
@property (nonatomic, retain) IBOutlet UIButton *networkBtn1; 
@property (nonatomic, retain) IBOutlet UIButton *networkBtn2; 
@property (nonatomic, retain) IBOutlet UIButton *networkBtn3; 
@property (nonatomic, retain) IBOutlet UIButton *otheXmppAcctBtn; 
@property (nonatomic, retain) IBOutlet UIButton *createNewAcctBtn; 

- (IBAction)openScreen:(id)sender;

- (id)initWithTitle:(NSString *)title;

- (UIViewController *)showNetworkLogin:(NSInteger)networkId;

@end
