#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

- (const xmlChar *)xmlChar
{
	return (const xmlChar *)[self UTF8String];
}

#ifdef GNUSTEP
- (NSString *)stringByTrimming
{
	return [self stringByTrimmingSpaces];
}
#else
- (NSString *)stringByTrimming
{
	NSMutableString *mStr = [self mutableCopy];
	CFStringTrimWhitespace((CFMutableStringRef)mStr);
	
	NSString *result = [mStr copy];
	
	[mStr release];
	return [result autorelease];
}
#endif

- (NSString *)trimWhitespace
{
	NSMutableString *mStr = [self mutableCopy];
	CFStringTrimWhitespace((CFMutableStringRef)mStr);
	
	NSString *result = [mStr copy];
	
	[mStr release];
	return [result autorelease];
}

#pragma mark -
#pragma mark These are user define PUBLIC methods
//for display on UI using TTStyleText parser
- (NSString *)htmlEncoding
{
	self = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	self = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	self = [self stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	
	return self;
}

@end
