/* 
 ChannelTopicCell.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "ChannelTopicCell.h"

#define CONTENT_TAG			234
#define GEO_AND_TIME_TAG	236

@interface ChannelTopicCell (SubviewFrames)

- (CGRect) avatarImageViewFrame;
- (CGRect) avatarImageBorderFrame;
- (CGRect) contentLabelFrame;
- (CGRect) geoLocAndTimeLabelFrame;
- (CGRect) rowShadowImageFrame;

@end

@implementation ChannelTopicCell

@synthesize postItem, avatarImageBorder, avatarImage, rowShadowImage, contentLabel, geoLocAndTimeLabel;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	
	CGFloat ret = 0.0;

	if ([object isKindOfClass: [PostItem class]]) {
		PostItem *postItem = (PostItem *)object;

		NSString *contentLabelHtml = [NSString stringWithFormat:@"%@", [postItem content]];
		
		CGSize maxSize = CGSizeMake(tableView.width, CGFLOAT_MAX);
		CGSize contentLabelSize = [[contentLabelHtml htmlEncoding] sizeWithFont:[Util fontContent]
									   constrainedToSize:maxSize 
										   lineBreakMode:UILineBreakModeWordWrap];
		
		ret = contentLabelSize.height + (TEXT_PADING * 2.0) + GEO_LOC_TIME_HEIGHT;
		NSLog(@"[postItem content] = %@, Content height = %f: and Geolocation text height = %f", [contentLabelHtml htmlEncoding], contentLabelSize.height, GEO_LOC_TIME_HEIGHT);
		if (ret < (AVATAR_SIZE_HEIGHT + 10.0 * 2.0)) ret = (AVATAR_SIZE_HEIGHT + 10.0 * 2.0);
	} 
	else {
		ret = (AVATAR_SIZE_HEIGHT + 10.0 * 2.0);
	}

	NSLog(@"HEIGHT: %f", ret);
	
	return ret;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	 if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {	
		self.contentView.backgroundColor = RGBCOLOR(196.0, 207.0, 210.0);
		
		//Avatar
		avatarImageBorder = [[UIImageView alloc] initWithFrame:CGRectZero];
		avatarImageBorder.image = [UIImage imageNamed:@"avatarFrame.png"];
		avatarImageBorder.backgroundColor = [UIColor clearColor];
		avatarImage = [[UIImageView alloc] initWithFrame: CGRectZero];
		avatarImage.contentMode = UIViewContentModeScaleAspectFit;
		avatarImage.backgroundColor = [UIColor clearColor];
		//[avatarImage addSubview:avatarImageBorder];
		//[avatarImage bringSubviewToFront:avatarImageBorder];
        [self.contentView addSubview:avatarImage];
		
		//Topic Details.
		contentLabel = (TTStyledTextLabel *) [self viewWithTag: CONTENT_TAG];
		if(contentLabel != nil)
			[contentLabel removeFromSuperview];
		
		contentLabel = [[TTStyledTextLabel alloc] initWithFrame: CGRectZero];
		[contentLabel setBackgroundColor:[UIColor clearColor]];
		[contentLabel setContentMode:UIViewContentModeTopLeft];
		[contentLabel setTextAlignment:UITextAlignmentLeft];
		[contentLabel setFont: [Util fontContent]];
		[contentLabel setHighlightedTextColor:RGBCOLOR(255.0, 255.0, 255.0)];
		[contentLabel setTag: CONTENT_TAG];
		[self.contentView addSubview:contentLabel];
		
		//Geo And Time.
		geoLocAndTimeLabel = (TTStyledTextLabel *) [self viewWithTag: GEO_AND_TIME_TAG];
		if(geoLocAndTimeLabel != nil)
			[geoLocAndTimeLabel removeFromSuperview];
		
		geoLocAndTimeLabel = [[TTStyledTextLabel alloc] initWithFrame:CGRectZero];
		[geoLocAndTimeLabel setBackgroundColor:[UIColor clearColor]];
		[geoLocAndTimeLabel setContentMode:UIViewContentModeTopRight];
		[geoLocAndTimeLabel setTextAlignment:UITextAlignmentRight];
		[geoLocAndTimeLabel setFont: [Util fontLocationTime]];
		[geoLocAndTimeLabel setHighlightedTextColor:RGBCOLOR(255.0, 255.0, 255.0)];
		[geoLocAndTimeLabel setTag: GEO_AND_TIME_TAG];
		[self.contentView addSubview:geoLocAndTimeLabel];
		 
		rowShadowImage = [[UIImageView alloc] initWithFrame:CGRectZero]; 
		rowShadowImage.image = [UIImage imageNamed:@"shadow.png"];
		rowShadowImage.hidden = YES;
		rowShadowImage.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:rowShadowImage];
	}
	
	return self;
}

#pragma mark LayoutSubviews Function
- (void)layoutSubviews {
    [super layoutSubviews];
	
	avatarImage.frame = [self avatarImageViewFrame];
	avatarImageBorder.frame = [self avatarImageBorderFrame];
	contentLabel.frame = [self contentLabelFrame];
	geoLocAndTimeLabel.frame = [self geoLocAndTimeLabelFrame];
	rowShadowImage.frame = [self rowShadowImageFrame];
}

#pragma mark SubviewFrames Function
- (CGRect) avatarImageViewFrame {
	return CGRectMake(CELL_START_X, CELL_START_Y, AVATAR_SIZE_WIDTH, AVATAR_SIZE_HEIGHT); 
}

- (CGRect) avatarImageBorderFrame
{
	return CGRectMake(-4.0, -4.0, AVATAR_SIZE_WIDTH + 6.0, AVATAR_SIZE_HEIGHT + 5.0);
}

- (CGRect) contentLabelFrame
{
	NSString *contentLabelHtml = [NSString stringWithFormat:@"%@", [postItem content]];

	CGSize maxSize = CGSizeMake(self.contentView.width, CGFLOAT_MAX);
	CGSize contentLabelSize = [[contentLabelHtml htmlEncoding] sizeWithFont:[Util fontContent]
												   constrainedToSize:maxSize 
													   lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat contentLabelHeight = contentLabelSize.height + CELL_START_Y;
	contentLabelHeight = (contentLabelHeight < (AVATAR_SIZE_HEIGHT + 10.0 * 2.0)) ? contentLabelHeight + TEXT_PADING/2 : contentLabelHeight;
	NSLog(@">>>>Height : %f and content = %@", contentLabelHeight, contentLabelHtml);

	return CGRectMake(avatarImage.frame.size.width + TEXT_PADING, CELL_START_Y, self.contentView.width - 70.0, contentLabelHeight);
}

- (CGRect) geoLocAndTimeLabelFrame
{
	NSString *geoLocAndTimeLabelHtml = [NSString stringWithFormat:@"%@ - %@", [postItem location], [Util getPrettyDate:[postItem postTime]]];	
	CGSize maxSize = CGSizeMake(self.contentView.width, CGFLOAT_MAX);
	CGSize geoLocAndTimeLabelSize = [geoLocAndTimeLabelHtml sizeWithFont:[Util fontLocationTime]
														   constrainedToSize:maxSize 
															   lineBreakMode:UILineBreakModeWordWrap];

	return CGRectMake(self.contentView.width - geoLocAndTimeLabelSize.width - TEXT_PADING/2, contentLabel.frame.size.height + TEXT_PADING/2, geoLocAndTimeLabelSize.width, GEO_LOC_TIME_HEIGHT);
}

- (CGRect) rowShadowImageFrame {
	
	return CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.size.height, self.contentView.frame.size.width, POST_TOPIC_SHADOW_HEIGHT);	
}

#pragma mark -
#pragma mark Post Item set accessor
- (void)setPostItem:(PostItem *)postedItem {
	
	[postItem release];
	postItem = [postedItem retain];

	NSString *contentLabelHtml = [NSString stringWithFormat:@"%@", [postItem content]];
	NSString *geoLocAndTimeLabelHtml = [NSString stringWithFormat:@"<span class='geoLocation'>%@ <span class='geoLocationTime'>- %@</span></span>", ([postItem location]) ? [postItem location] : @"", [Util getPrettyDate:[postItem postTime]]];
	
	avatarImage.image = [UIImage imageNamed: @"contact.png"];
	[contentLabel setText: [TTStyledText textFromXHTML:[contentLabelHtml htmlEncoding] lineBreaks:YES URLs:YES]];	
	[geoLocAndTimeLabel setText: [TTStyledText textFromXHTML:geoLocAndTimeLabelHtml lineBreaks:YES URLs:YES]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
	TT_RELEASE_SAFELY(contentLabel);
	TT_RELEASE_SAFELY(geoLocAndTimeLabel);
	
	TT_RELEASE_SAFELY(avatarImage);
	TT_RELEASE_SAFELY(avatarImageBorder);
	
	[super dealloc];
}


@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark ChannelCommentCell
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ChannelCommentCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.contentView.backgroundColor = RGBCOLOR(255.0, 255.0, 255.0);

	}
	
	return self;
}

@end
