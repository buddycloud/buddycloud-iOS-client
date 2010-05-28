//
//  PostCellController.m
//  Buddycloud
//
//  Created by Ross Savage on 5/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "PostCellController.h"


@implementation PostCellController
@synthesize authorLabel, contentLabel;
@synthesize iconImage;

- (void)dealloc {
	[authorLabel release];
	[contentLabel release];
	[iconImage release];
	
    [super dealloc];
}

@end

@implementation PostTopicCellController
@synthesize addCommentButton;

- (void)dealloc {
	[addCommentButton release];
	
    [super dealloc];
}

@end
