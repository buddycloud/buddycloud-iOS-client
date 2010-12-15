/* 
 UserAccountMsgViewController.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/12/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>


@interface UserAccountMsgViewController :  TTViewController {
	
	UILabel *successMsgLabel;
	UIButton *exploreBtn;
	
	NSString *_username;
	NSString *_password;
}

@property (nonatomic, retain) IBOutlet UILabel *successMsgLabel; 
@property (nonatomic, retain) IBOutlet UIButton *exploreBtn; 

@property (nonatomic, retain) NSString *_username;
@property (nonatomic, retain) NSString *_password;

- (IBAction)exploreBuddyCloud:(id)sender;

- (id)initWithTitle:(NSString *)title withUserName:(NSString *)username withPassword:(NSString *)password; 
@end
