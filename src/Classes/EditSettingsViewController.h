//
//  EditSettingsViewController.h
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditSettingsViewController : UITableViewController {

	@private
	NSString *settingsName;
}
@property (nonatomic, copy) NSString *settingsName;

- (id) initWithSettingName:(NSString *) newSettingsName;
@end
