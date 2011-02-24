/* 
 BuddyCloudStyleSheet.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/22/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "BuddyCloudStyleSheet.h"

@implementation BuddyCloudStyleSheet

- (TTStyle*)geoLocation {
	return [TTTextStyle styleWithFont:[Util fontLocationTime] color:RGBCOLOR(201, 0, 36) next: nil];
}

- (TTStyle*)geoLocationTime {
	return [TTTextStyle styleWithFont:[Util fontLocationTime] color:RGBCOLOR(16, 57, 71) next: nil];
}


- (UIColor *)navigationBarColor {
	return RGBCOLOR (16, 57, 71);
}

- (UIColor *)appBKgroundColor {
	return RGBCOLOR(196.0, 207.0, 210.0);
}

@end
