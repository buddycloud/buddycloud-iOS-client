//
//  PostItem.m
//  Buddycloud
//
//  Created by Ross Savage on 5/22/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "PostItem.h"
#import <Foundation/NSDateFormatter.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PostItem implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PostItem
@synthesize node;
@synthesize entryId, commentId;
@synthesize postTime;
@synthesize authorName, authorJid;
@synthesize authorAffiliation;
@synthesize location, content;
@synthesize isRead;

- (id)initWithNode:(NSString *)aNode
{
	if (self = [super init]) {
		[self setNode: aNode];
	}
	
	return self;
}

- (void)dealloc
{
	[node release];
	[postTime release];
	[authorName release];
	[authorJid release];
	[location release];
	[content release];
	
	[super dealloc];
}

- (void)setPostTimeFromString:(NSString *)formattedDate
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//	[dateFormatter setFormatterBehavior: NSDateFormatterBehavior10_4];
//	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName: @"UTC"]];
	[dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss"];
	
	NSDate *pt = [dateFormatter dateFromString: [formattedDate stringByReplacingOccurrencesOfString: @"Z" withString: @"-0000"]];
	[pt retain];
	[self setPostTime: pt];
}

@end
