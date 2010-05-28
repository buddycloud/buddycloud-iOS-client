//
//  PostCellController.h
//  Buddycloud
//
//  Created by Ross Savage on 5/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostCellController : UIViewController {
	UILabel *authorLabel;
	UILabel *contentLabel;
	
	UIImageView *iconImage;
}

@property(nonatomic, retain) IBOutlet UILabel *authorLabel, *contentLabel;
@property(nonatomic, retain) IBOutlet UIImageView *iconImage;

@end

@interface PostTopicCellController : PostCellController {
	UIButton *addCommentButton;
}

@property(nonatomic, retain) IBOutlet UIButton *addCommentButton;

@end
