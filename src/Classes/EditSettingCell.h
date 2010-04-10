//
//  EditSettingCell.h
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditSettingCell : UITableViewCell <UITextFieldDelegate>
{

	UITextField *textFieldToEdit;
}

@property (retain, nonatomic) UITextField *textFieldToEdit;

@end
