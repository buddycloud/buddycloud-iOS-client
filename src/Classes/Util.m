//
//  Util.m
//  Buddycloud
//
//  Created by Ben on 7/22/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "Util.h"
#import <dlfcn.h>

@implementation Util

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSUInteger) loadFonts {
	static bool hasLoaded = false;
	static NSUInteger newFontCount;
	if (!hasLoaded) {
		NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.GraphicsServices"];
		const char *frameworkPath = [[frameworkBundle executablePath] UTF8String];
		if (frameworkPath) {
			void *graphicsServices = dlopen(frameworkPath, RTLD_NOLOAD | RTLD_LAZY);
			if (graphicsServices) {
				BOOL (*GSFontAddFromFile)(const char *) = dlsym(graphicsServices, "GSFontAddFromFile");
				if (GSFontAddFromFile)
					for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"TTF" inDirectory:nil])
						newFontCount += GSFontAddFromFile([fontFile UTF8String]);
			}
		}
		hasLoaded = true;
	}
	return newFontCount;
}

+ (UIFont*) fontContent {
	static UIFont *ret;
	if (ret == nil) {
		[Util loadFonts];
		ret = [UIFont fontWithName: @"Corbel" size:14.0f];
	}
	return ret;
}

+ (UIFont*) fontLocationTime {
	static UIFont *ret;
	if (ret == nil) {
		[Util loadFonts];
		ret = [UIFont fontWithName: @"Corbel" size:10.0f];
	}
	return ret;
}

@end
