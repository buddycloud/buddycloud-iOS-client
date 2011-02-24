/* 
 ChannelDetailHeader.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/31/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>

#define CHANNEL_AVATAR_WIDTH		60
#define CHANNEL_AVATAR_HEIGHT		60

@interface ChannelDetailHeader : TTView {
	
	TTStyledTextLabel *statusLabel;
	TTStyledTextLabel *contentLabel;
	
	UIImageView *iconImage;
}

@property(nonatomic, retain) TTStyledTextLabel *statusLabel;
@property(nonatomic, retain) TTStyledTextLabel *contentLabel;
@property(nonatomic, retain) UIImageView *iconImage;

- (id)initWithFrame:(CGRect)newFrame;

@end
