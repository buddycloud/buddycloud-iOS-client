/* 
 LoginViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>


@interface LoginViewController :  TTViewController <UITextFieldDelegate> {
	
	NSInteger networkID; 
	
	UILabel *loginTitleLabel;
	UILabel *userNameLabel;
	UILabel *passwordLabel;
	UILabel *loginAutomaticallyLabel;
	
	UITextField *userNameTxtField;
	UITextField *passwordTxtField;
	UISwitch	*loginAutomaticallyToggle;
	
	UIToolbar *loginToolBar;
}

@property (nonatomic) NSInteger networkID; 
@property (nonatomic, retain) IBOutlet UILabel *loginTitleLabel; 
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel; 
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel; 
@property (nonatomic, retain) IBOutlet UILabel *loginAutomaticallyLabel;

@property (nonatomic, retain) IBOutlet UITextField *userNameTxtField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTxtField;
@property (nonatomic, retain) IBOutlet UISwitch	*loginAutomaticallyToggle;

@property (nonatomic, retain) IBOutlet UIToolbar *loginToolBar; 

- (id)initWithTitle:(NSString *)title withNetworkID:(NSInteger)networkId;

- (void)login:(id)sender;
- (void)cancel:(id)sender;
- (void)showErrorMsg:(NSString *)sMsg;
- (void)removeErrorMsg;

- (void)createNewAccount:(id)sender;
- (void)forgetPassword:(id)sender;


@end
