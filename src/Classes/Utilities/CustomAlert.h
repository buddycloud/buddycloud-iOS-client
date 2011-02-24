/* 
 CustomAlert.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/18/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>


@interface CustomAlert : UIAlertView
{
	UITextField	*textField;
}

@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;

+ (void) setBackgroundColor:(UIColor *) background 
			withStrokeColor:(UIColor *) stroke;

- (id)initAlertWithTxtFieldTitle:(NSString *)title showPreMsg:(NSString *)message 
					  keypadType:(UIKeyboardType )keypadType delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

+ (void)showAlertMessageWithTitle:(NSString *)title showPreMsg:(NSString *)sMsg;
+ (BOOL) phoneNoLengthValidation:(NSString *)phoneNo;
- (NSString *) phoneNoValidation:(NSString *)phoneNo;

@end
