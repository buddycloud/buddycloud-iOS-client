/* 
 SpiralLoadingView.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/12/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "SpiralLoadingView.h"

#define CENTERED_SCREEN_HEIGHT 60

@implementation SpiralLoadingView

/* Show activity view.
 *	- style : TTStyle activity defined.
 *	- sMsg  : Text message need to display. 
 *	- activityFrame : customize activty frame. 
 */
- (void)showActivityLabelInCenter:(TTActivityLabelStyle)style withText:(NSString *)sMsg {
	[self showActivityLabelWithStyle:style withText:sMsg withTransparentSheet:NO withActivityFrame:CGRectMake(0.0, (([UIScreen mainScreen].applicationFrame.size.height - [TTNavigator navigator].topViewController.navigationController.navigationBar.height) - CENTERED_SCREEN_HEIGHT) / 2, 
																											  [UIScreen mainScreen].bounds.size.width, CENTERED_SCREEN_HEIGHT)];
}

- (void)showActivityLabelInCenter:(TTActivityLabelStyle)style withTransparentSheet:(BOOL)transparentSheet withText:(NSString *)sMsg {
	[self showActivityLabelWithStyle:style withText:sMsg withTransparentSheet:transparentSheet withActivityFrame:CGRectMake(0.0, (([UIScreen mainScreen].applicationFrame.size.height - [TTNavigator navigator].topViewController.navigationController.navigationBar.height) - CENTERED_SCREEN_HEIGHT) / 2, 
																											  [UIScreen mainScreen].bounds.size.width, CENTERED_SCREEN_HEIGHT)];
}

/* Show activity view.
 *	- style : TTStyle activity defined.
 *	- sMsg  : Text message need to display. 
 */
- (void)showActivityLabelWithStyle:(TTActivityLabelStyle)style withText:(NSString *)sMsg withActivityFrame:(CGRect)activityFrame {
	[self showActivityLabelWithStyle:style withText:sMsg withTransparentSheet:NO withActivityFrame:activityFrame];
}

/* Show activity view.
 *	- style : TTStyle activity defined.
 *	- sMsg  : Text message need to display.
 *	- transparentSheet : Transparent sheet enable/disable.
 *	- activityFrame : customize activty frame.
 */
- (void)showActivityLabelWithStyle:(TTActivityLabelStyle)style withText:(NSString *)sMsg withTransparentSheet:(BOOL)transparentSheet withActivityFrame:(CGRect)activityFrame {
	
	UIViewController *viewController = (TTViewController*)[TTNavigator navigator].visibleViewController;
	
	if(transparentSheet)
	{
		UIWindow *window = [TTNavigator navigator].window;
		if (window) {
			if (![[window viewWithTag:ACTIVITY_TRANSPARENT_SHEET_TAG] isKindOfClass:[UIView class]]) {
				
				UIView *transparentSheetView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
				transparentSheetView.opaque = NO;
				transparentSheetView.backgroundColor = [UIColor blackColor];
				transparentSheetView.alpha = 0.3;
				[transparentSheetView setTag:ACTIVITY_TRANSPARENT_SHEET_TAG];
				
				[window addSubview:transparentSheetView];
			}
		}
	}
	
	if (viewController) {

		if (![[viewController.view viewWithTag:ACTIVITY_LABEL_TAG] isKindOfClass:[TTActivityLabel class]]) {
			
			TTActivityLabel *loadingView = [[[TTActivityLabel alloc] initWithStyle:style] autorelease];
			loadingView.text = sMsg;
			loadingView.frame = activityFrame;
			[loadingView sizeToFit];
			[loadingView setTag:ACTIVITY_LABEL_TAG];
			[viewController.view addSubview:loadingView];
		}
	}
}

/*
 * Stop the activity view.
 */
- (void)stopActivity {
	
	UIViewController *viewController = (TTViewController*)[TTNavigator navigator].visibleViewController;
	UIWindow *window = [TTNavigator navigator].window;
	
	if ([[window viewWithTag:ACTIVITY_TRANSPARENT_SHEET_TAG] isKindOfClass:[UIView class]]) {
		UIView *transparentSheetView = (UIView *)[window viewWithTag:ACTIVITY_TRANSPARENT_SHEET_TAG];
		[transparentSheetView removeFromSuperview];	
	}
	
	if ([[viewController.view viewWithTag:ACTIVITY_LABEL_TAG] isKindOfClass:[TTActivityLabel class]]) {
		TTActivityLabel *loadingView = (TTActivityLabel *)[viewController.view viewWithTag:ACTIVITY_LABEL_TAG];
		[loadingView removeFromSuperview];	
	}
}

@end
