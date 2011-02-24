//
//  CustomizedTableCell.m
//  Buddycloud
//
//  Created by Deminem on 1/6/11.
//  Copyright 2011 buddycloud. All rights reserved.
//

#import "CustomizedTableCell.h"


@implementation CustomizedTableCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CustomTableCellWithLeftTxt - text on left.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CustomTableCellWithLeftTxt
	
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

	
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ToggleButtonTableCell - ToggleButton on left side.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define toggleWidth		100.0
#define toggleHeight	27.0

@interface ToggleButtonTableCell (SubviewFrames)

- (CGRect) toggleButtonViewFrame;
@end

@implementation ToggleButtonTableCell
@synthesize toggleBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		[self.contentView setBackgroundColor: [UIColor clearColor]];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		
		toggleBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
		toggleBtn.contentMode = UIViewContentModeScaleAspectFit;
		toggleBtn.backgroundColor = [UIColor clearColor];
		toggleBtn.on = NO; // By default;
		
		[self.contentView addSubview:toggleBtn];
		
    }
    return self;
}

#pragma mark LayoutSubviews Function
- (void)layoutSubviews {
    [super layoutSubviews];
	
	toggleBtn.frame = [self toggleButtonViewFrame];
}

#pragma mark SubviewFrames Function
- (CGRect) toggleButtonViewFrame
{
	return CGRectMake(self.contentView.frame.size.width - toggleWidth, self.contentView.frame.size.height/2 - toggleHeight/2, 0, toggleHeight);
}




-(void)dealloc {
	TT_RELEASE_SAFELY(toggleBtn);
	
	[super dealloc];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonTableCell - Button on left side.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define buttonWidth		72.0
#define buttonHeight	29.0

@interface ButtonTableCell (SubviewFrames)

- (CGRect) leftButtonViewFrame;
- (void)onButtonClick:(id)sender;

@end

@implementation ButtonTableCell
@synthesize leftButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		[self.contentView setBackgroundColor: [UIColor clearColor]];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		
		leftButton = [UIButton buttonWithType: UIButtonTypeRoundedRect]; 
		leftButton.frame = CGRectZero;
		//[leftButton setTitle:@"Button" forState:UIControlStateNormal];
		leftButton.contentMode = UIViewContentModeScaleAspectFit;
		leftButton.backgroundColor = [UIColor clearColor];
		[leftButton setTag: BTN_ACTION_NONE];
		[leftButton addTarget:self action:@selector(onButtonClick:) forControlEvents: UIControlEventTouchUpInside];
		
		[self.contentView addSubview:leftButton];
    }
	
    return self;
}

#pragma mark LayoutSubviews Function
- (void)layoutSubviews {
    [super layoutSubviews];
	
	leftButton.frame = [self leftButtonViewFrame];
}

#pragma mark SubviewFrames Function
- (CGRect) leftButtonViewFrame
{
	return CGRectMake(self.contentView.frame.size.width - buttonWidth, self.contentView.frame.size.height/2 - buttonHeight/2, buttonWidth - 5.0, buttonHeight);
}

#pragma mark Button Delegate Function
- (void)onButtonClick:(id)sender {
	if (delegate && [delegate respondsToSelector:@selector(onButtonClick:)]) {
		[delegate performSelector:@selector(onButtonClick:) withObject:sender];	
	}
}

-(void)dealloc {
	
	[super dealloc];
}
@end