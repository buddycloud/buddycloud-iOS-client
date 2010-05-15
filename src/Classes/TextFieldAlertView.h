//
//  TextFieldAlertView.h
//  Buddycloud
//
//  Created by Ross Savage on 5/15/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextFieldAlertView : UIAlertView {
	UITextField *textField;
}

@property(nonatomic, retain) UITextField *textField;
@property(readonly) NSString* enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end
