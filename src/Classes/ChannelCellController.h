//
//  ChannelCellController.h
//  Buddycloud
//
//  Created by Ross Savage on 5/19/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelCellController : UIViewController {
	UILabel *titleLabel;
	UILabel *rankLabel;
	UILabel *descriptionLabel;
	
	UIImageView *imageView;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *rankLabel;
@property(nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property(nonatomic, retain) IBOutlet UIImageView *imageView;

@end
