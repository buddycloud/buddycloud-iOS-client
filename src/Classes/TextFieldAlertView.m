//
//  TextFieldAlertView.m
//  Buddycloud
//
//  Created by Ross Savage on 5/15/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "TextFieldAlertView.h"

@implementation TextFieldAlertView
@synthesize textField;
@dynamic enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle
{	
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil]) {
        [self setTextField: [[UITextField alloc] initWithFrame: CGRectMake(12.0, 45.0, 260.0, 22.0)]]; 
        [textField setBackgroundColor: [UIColor whiteColor]];
		[textField setPlaceholder: message];
        [self addSubview: textField];

        [self setTransform: CGAffineTransformMakeTranslation(0.0, 120.0)];
    }
	
    return self;
}

- (void)dealloc
{
	[textField release];
	
	[super dealloc];
}

- (void)show
{
	[textField becomeFirstResponder];
	[super show];
}

- (NSString *)enteredText
{
	return textField.text;
}

@end
