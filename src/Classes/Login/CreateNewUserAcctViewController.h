/* 
 CreateNewUserAcctViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/11/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */
 
#import <Foundation/Foundation.h>
#import "UserAccountMsgViewController.h"

@interface CreateNewUserAcctViewController : TTViewController <UITextFieldDelegate> {
	
	UILabel *createTitleLabel;
	UILabel *registerTitleLabel;
	
	UILabel *userNameLabel;
	UILabel *newPasswordLabel;
	
	UITextField *userNameTxtField;
	UITextField *newPasswordTxtField;
	
	UIButton *helpBtn;

}

@property (nonatomic, retain) IBOutlet UILabel *createTitleLabel; 
@property (nonatomic, retain) IBOutlet UILabel *registerTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel; 
@property (nonatomic, retain) IBOutlet UILabel *newPasswordLabel; 

@property (nonatomic, retain) IBOutlet UITextField *userNameTxtField;
@property (nonatomic, retain) IBOutlet UITextField *newPasswordTxtField;

@property (nonatomic, retain) IBOutlet UIButton *helpBtn;

- (void)join:(id)sender;
- (void)cancel:(id)sender;

- (void)showErrorMsg:(NSString *)sMsg; 
- (void)removeErrorMsg;

@end
