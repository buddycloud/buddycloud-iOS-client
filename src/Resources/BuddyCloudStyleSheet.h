/* 
 BuddyCloudStyleSheet.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/22/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>

#define APPSTYLESHEET ((id)[TTStyleSheet globalStyleSheet])
#define APPSTYLEVAR(_VARNAME) [APPSTYLESHEET _VARNAME]

@interface BuddyCloudStyleSheet : TTDefaultStyleSheet {

}

- (TTStyle*)geoLocation;
- (TTStyle*)geoLocationTime;

- (UIColor *)navigationBarColor;
- (UIColor *)appBKgroundColor;

@end
