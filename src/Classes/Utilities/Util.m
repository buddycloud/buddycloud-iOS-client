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

+ (NSString*) getPrettyDate:(NSDate *)date {
	NSString *ret;
	double ti = -(double)[date timeIntervalSinceNow];
	if (ti < 10) {
		ret = @"A few seconds ago";
	} else if (ti < 60) {
		ret = @"Less than a minute ago";
	} else if (ti < 2*60) {
		ret = @"About a minute ago";
	} else if (ti < 60*60) {
		ret = [NSString stringWithFormat:@"%i minutes ago", (int)(ti / 60)];
	} else if (ti < 24*60*60) {
		ret = [NSString stringWithFormat:@"%i hours ago", (int)(ti / 3600)];
	} else if (ti < 7*24*60*60) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"EEE 'at' HH:mm"];
		ret = [df stringFromDate:date];
	} else if (ti < 365*24*60*60) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"dd.MM HH:mm"];
		ret = [df stringFromDate:date];
	} else {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"dd.MM.yy HH:mm"];
		ret = [df stringFromDate:date];
	}
	return ret;
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
		ret = [UIFont fontWithName: @"Corbel" size:12.0f];
	}
	return ret;
}

+ (UIColor*) appBKGroundBeigeColor {
	static UIColor *ret;
	if (ret == nil) {
		ret = [UIColor colorWithRed:243.0 green:241.0 blue:229.0 alpha:0];
	}
	return ret;
}

+ (UIColor*) appBKGroundLightGreyColor {
	static UIColor *ret;
	if (ret == nil) {
		ret = [UIColor colorWithRed:206.0 green:216.0 blue:218.0 alpha:0];
	}
	return ret;
}

/*
 * This method will generate the url query string with dictionary params.
 */
+ (NSURL*) generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* val = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* pair = [NSString stringWithFormat:@"%@=%@", key, val];
			[pairs addObject:pair];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

/*
 * This method will find the params in url query string and parse all the params as key/value binding in dictionaary.
 */
+ (NSMutableDictionary*) getQueryPramsDict:(NSString*)urlQueryString {
	NSMutableDictionary *paramsDict = nil;
	
	if (urlQueryString != nil && ![urlQueryString isEmptyOrWhitespace]) {
		NSRange range = [urlQueryString rangeOfString:@"?" options:NSLiteralSearch];
		NSString *query = (range.location != NSNotFound) ? [urlQueryString substringFromIndex:(range.location + 1)] : nil;
						 
		if ([query length] > 0) {
			NSArray *keyValueParams = [query componentsSeparatedByString:@"&"];
			paramsDict = [[[NSMutableDictionary alloc] initWithCapacity:[keyValueParams count]] autorelease];
			
			for (NSString *params in keyValueParams) {
				NSRange paramRange = [params rangeOfString:@"=" options:NSLiteralSearch];
				
				if (paramRange.location != NSNotFound) {
					[paramsDict setObject:[params substringFromIndex:(paramRange.location + 1)] 
								   forKey:[params substringToIndex:paramRange.location]];
				}
			}
		}
	}
	
	return paramsDict;
}



//- (NSMutableDictionary *) getDictionaryPrams:(NSArray*)params {
//	NSMutableDictionary *paramsList = [[[NSMutableDictionary alloc] init] autorelease];
//	@try {
//		if ([params count] > 0) {
//			for (int i=0; i < [params count]; i++) {
//				NSArray *subParams= [(NSString*)[params objectAtIndex:i] componentsSeparatedByString:@"="];
//				[paramsList setObject:[subParams objectAtIndex:1] forKey:[subParams objectAtIndex:0]];
//			}//for
//		}//if
//	}//try
//	@catch(NSException *ex) {
//		NSLog(@"getDictionaryPrams method TTNavigationCenter exception :%@",ex);
//	}//catch
//	@finally {
//		return paramsList;
//	}//finally
//}
@end
