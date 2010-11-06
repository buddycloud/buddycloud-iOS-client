//
//  PostItem.h
//  Buddycloud
//
//  Created by Ross Savage on 5/22/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelItem.h"
#import "DDXML.h"

typedef long long superlong;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PostItem definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface PostItem : NSObject {
	NSString *node;
	
	superlong entryId;
	superlong commentId;
	 
	NSDate *postTime;
	
	NSString *authorName;
	NSString *authorJid;
	ChannelAffiliation authorAffiliation;
	
	NSString *location;
	NSString *content;
	
	BOOL isRead;
}

@property(nonatomic, retain) NSString *node;
@property(nonatomic) superlong entryId, commentId;
@property(nonatomic, retain) NSDate *postTime;
@property(nonatomic, retain) NSString *authorName, *authorJid;
@property(nonatomic) ChannelAffiliation authorAffiliation;
@property(nonatomic, retain) NSString *location, *content;
@property(nonatomic) BOOL isRead;

- (id)initWithChannelNode:(NSString *)node;

- (void)setPostTimeFromString:(NSString *)formattedDate;

@end
