
//
//  FollowerCellController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FollowerCellController : UIViewController {
	UILabel *nameLabel;
	UILabel *descriptionLabel;
	
	UILabel *geoPreviousLabel;
	UILabel *geoCurrentLabel;

	UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *geoPreviousLabel;
@property (nonatomic, retain) IBOutlet UILabel *geoCurrentLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
