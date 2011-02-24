/* 
 SpiralLoadingView.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/12/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Activity Bezel & Transparent View Tag
#define ACTIVITY_LABEL_TAG								1111
#define ACTIVITY_TRANSPARENT_SHEET_TAG					2222
#define ACTIVITY_TRANSPARENT_SHEET_TAG_FB				3333

@interface SpiralLoadingView : NSObject {

}

- (void)showActivityLabelInCenter:(TTActivityLabelStyle)style withText:(NSString *)sMsg;
- (void)showActivityLabelInCenter:(TTActivityLabelStyle)style withTransparentSheet:(BOOL)transparentSheet withText:(NSString *)sMsg;
- (void)showActivityLabelWithStyle:(TTActivityLabelStyle)style withText:(NSString *)sMsg withActivityFrame:(CGRect)activityFrame;
- (void)showActivityLabelWithStyle:(TTActivityLabelStyle)style withText:(NSString *)sMsg withTransparentSheet:(BOOL)transparentSheet withActivityFrame:(CGRect)activityFrame;



- (void)stopActivity;
@end
