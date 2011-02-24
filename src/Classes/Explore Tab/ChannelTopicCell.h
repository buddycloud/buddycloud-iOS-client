/* 
 ChannelTopicCell.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "PostItem.h"

@class PostItem;
#define AVATAR_SIZE_WIDTH	44.0
#define AVATAR_SIZE_HEIGHT	49.0
#define TEXT_PADING				18.0
#define CELL_START_X			10.0
#define CELL_START_Y			10.0
#define GEO_LOC_TIME_HEIGHT		15.0
#define SHADOW_HEIGHT			23.0

#define POST_TOPIC_SHADOW_HEIGHT	23.0

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ChannelTopicCell
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ChannelTopicCell : TTTableViewCell {

	PostItem *postItem;
	TTStyledTextLabel *geoLocAndTimeLabel;
	TTStyledTextLabel *contentLabel;
	
	UIImageView *avatarImage;
	UIImageView *avatarImageBorder;
	
	UIImageView *rowShadowImage;
}

@property (nonatomic, retain) PostItem *postItem;
@property(nonatomic, retain) TTStyledTextLabel *geoLocAndTimeLabel;
@property(nonatomic, retain) TTStyledTextLabel *contentLabel;
@property(nonatomic, retain) UIImageView *avatarImage;
@property(nonatomic, retain) UIImageView *avatarImageBorder;
@property(nonatomic, retain) UIImageView *rowShadowImage;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ChannelCommentCell
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ChannelCommentCell : ChannelTopicCell {
	

}

@end