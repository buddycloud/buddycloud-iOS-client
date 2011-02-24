
//
//  ExploreCellController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExploreCellController : UIViewController {
	UILabel *titleLabel;
	UILabel *descriptionLabel;

	UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
