//
//  SettingsViewController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UITableViewController {

	UITextField *serverTextField;
	UITextField *usernameTextField;
	UITextField *passwordTextField;
}

@property (nonatomic, retain) UITextField *serverTextField;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

- (UITextField *) createTextField;

@end
