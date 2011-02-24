/* 
 ChannelDetailHeader.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/31/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "ChannelDetailHeader.h"

#define CHANNEL_DESC_TAG			22
#define CHANNEL_STATUS_TAG			23	

@implementation ChannelDetailHeader

@synthesize iconImage, contentLabel, statusLabel;

- (id)initWithFrame:(CGRect)newFrame {
	if (self = [super initWithFrame: newFrame]) {	
		self.backgroundColor = RGBCOLOR(196.0, 207.0, 210.0);
		
		//Avatar.
		UIImageView *iconImageFrame = [[[UIImageView alloc] initWithFrame:CGRectMake(newFrame.origin.x - 1.0, newFrame.origin.y - 4.0, CHANNEL_AVATAR_WIDTH + 2.0, CHANNEL_AVATAR_HEIGHT + 6.0)] autorelease];
		iconImageFrame.image = [UIImage imageNamed:@"icon.png"];
		iconImageFrame.backgroundColor = [UIColor clearColor];
		
		iconImage = [[UIImageView alloc] initWithFrame: CGRectMake(newFrame.origin.x + 7.0, newFrame.origin.y + 10.0, CHANNEL_AVATAR_WIDTH, CHANNEL_AVATAR_HEIGHT)];
		iconImage.contentMode = UIViewContentModeScaleAspectFit;
		iconImage.backgroundColor = [UIColor clearColor];
		[iconImage addSubview:iconImageFrame];
		[iconImage bringSubviewToFront:iconImageFrame];
        [self addSubview:iconImage];
		
		//Title & Description.
		contentLabel = (TTStyledTextLabel *) [self viewWithTag: CHANNEL_DESC_TAG];
		if(contentLabel != nil)
			[contentLabel removeFromSuperview];
		
		contentLabel = [[TTStyledTextLabel alloc] initWithFrame: CGRectMake(iconImage.frame.size.width + 17.0, iconImage.frame.origin.y, 233.0, 60.0)];
		[contentLabel setBackgroundColor:[UIColor clearColor]];
		[contentLabel setContentMode:UIViewContentModeTopLeft];
		[contentLabel setTextAlignment:UITextAlignmentLeft];
		[contentLabel setFont: [Util fontContent]];
		[contentLabel setHighlightedTextColor:RGBCOLOR(255.0, 255.0, 255.0)];
		
		[contentLabel setTag: CHANNEL_DESC_TAG];
		[self addSubview:contentLabel];
		
		//Status.
		statusLabel = (TTStyledTextLabel *) [self viewWithTag: CHANNEL_STATUS_TAG];
		if(statusLabel != nil)
			[statusLabel removeFromSuperview];
		
		statusLabel = [[TTStyledTextLabel alloc] initWithFrame: CGRectMake(contentLabel.frame.origin.x, contentLabel.size.height, 233.0, 20.0)];
		[statusLabel setBackgroundColor:[UIColor clearColor]];
		[statusLabel setContentMode:UIViewContentModeTopLeft];
		[statusLabel setTextAlignment:UITextAlignmentLeft];
		[statusLabel setFont: [Util fontContent]];
		[statusLabel setHighlightedTextColor:RGBCOLOR(255.0, 255.0, 255.0)];
		
		[statusLabel setTag: CHANNEL_STATUS_TAG];
		[self addSubview:statusLabel]; 
	}
	
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
	TT_RELEASE_SAFELY(contentLabel);
	TT_RELEASE_SAFELY(statusLabel);
	
	TT_RELEASE_SAFELY(iconImage);
	
	[super dealloc];
}

@end