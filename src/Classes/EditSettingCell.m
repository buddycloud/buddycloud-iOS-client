//
//  EditSettingCell.m
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "EditSettingCell.h"


@implementation EditSettingCell

@synthesize textFieldToEdit;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void) setTextFieldToEdit:(UITextField *)newTextField
{
	if (self.textFieldToEdit != nil)
	{
		[self.textFieldToEdit release];
		self.textFieldToEdit = nil;
	}
	textFieldToEdit = newTextField;
	[self.contentView addSubview:self.textFieldToEdit];
	[self.textFieldToEdit setDelegate:self];
	[self.textFieldToEdit setText:@"test"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	if (self.textFieldToEdit)
	{
		self.frame = [self.textFieldToEdit frame];
	}
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	NSLog(@"Should begin editing");
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
