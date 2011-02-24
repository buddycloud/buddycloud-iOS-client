//
//  ChannelItem.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "ChannelItem.h"


@implementation ChannelItem
@synthesize affiliation, subscription;
@synthesize rank;

// Parse a channel affiliation string
+ (ChannelAffiliation) affiliationFromString:(NSString*)str
{
	if ([str isEqualToString:@"none"]) {
		return CHANAFF_NONE;
	} else if ([str isEqualToString:@"owner"]) {
		return CHANAFF_OWNER;
	} else if ([str isEqualToString:@"moderator"]) {
		return CHANAFF_MODERATOR;
	} else if ([str isEqualToString:@"publisher"]) {
		return CHANAFF_PUBLISHER;
	} else if ([str isEqualToString:@"member"]) {
		return CHANAFF_MEMBER;
	} else {
		return CHANAFF_NONE;
	}
}

// Parse a channel affiliation into string
+ (NSString *) stringFromAffiliation:(ChannelAffiliation)channelAffiliation
{
	if (channelAffiliation == CHANAFF_NONE) {
		return @"none";
	} else if (channelAffiliation == CHANAFF_OWNER) {
		return @"owner";
	} else if (channelAffiliation == CHANAFF_MODERATOR) {
		return @"moderator";
	} else if (channelAffiliation == CHANAFF_PUBLISHER) {
		return @"publisher";
	} else if (channelAffiliation == CHANAFF_MEMBER) {
		return @"member";
	} else {
		return @"none";
	}
}

// Parse a channel subscription string
+ (ChannelSubscription) subscriptionFromString:(NSString*)str
{
	if ([str isEqualToString:@"none"]) {
		return CHANSUB_NONE;
	} else if ([str isEqualToString:@"pending"]) {
		return CHANSUB_PENDING;
	} else if ([str isEqualToString:@"subscribed"]) {
		return CHANSUB_SUBSCRIBED;
	} else {
		return CHANSUB_NONE;
	}
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Channel Detail Item
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ChannelDetailItem

@synthesize owner, popularity, subscribers, channelAffilationInfo, geoCordinateInfo;

- (id)initWithChannelItem:(ChannelItem *)item {
	if (self = [super init]) {
		channelAffilationInfo = [[NSMutableDictionary alloc] initWithCapacity: 10];
		[self setChannelItem: item];
	}
	
	return self;
}

- (id)initWithOwner:(NSString *)sOwner withPopularity:(int)iPopularity withSubscribers:(int)iSubscribers {
	if (self = [super init]) {	
		self.owner = sOwner;
		self.popularity = iPopularity;
		self.subscribers = iSubscribers;
	}
	
	return self;
}

- (void)setChannelItem:(ChannelItem *)channelItem {

	[self setTitle: channelItem.title];
	[self setIdent: channelItem.ident];
	[self setDescription: channelItem.description];
	[self setLastUpdated: channelItem.lastUpdated];
	[self setAffiliation: channelItem.affiliation];
	[self setSubscription: channelItem.subscription];
	[self setRank: channelItem.rank];
}

//- (NSInteger)getNoOfAffiliationByType:(ChannelAffiliation)channelAffiliation {
//	
//	NSInteger noOfAffiliations = 0;
//	
//	if (channelAffilationInfo) {
//		NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"SELF like[c] \"%@\"", [ChannelItem stringFromAffiliation: channelAffiliation]]];
//		noOfAf filiations = [[[channelAffilationInfo allValues] filteredArrayUsingPredicate: predicate] count];
//		
//		NSLog(@"Test : %@", [[channelAffilationInfo allValues] filteredArrayUsingPredicate: predicate]);
//	}
//	
//	return noOfAffiliations;
//}


- (NSInteger)getNoOfAffiliationByType:(ChannelAffiliation)channelAffiliation {
	
	NSInteger noOfAffiliations = 0;
	
	if (channelAffilationInfo) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"SELF like[c] \"%@\"", [ChannelItem stringFromAffiliation: channelAffiliation]]];
		noOfAffiliations = [[[channelAffilationInfo allValues] filteredArrayUsingPredicate: predicate] count];
		
		//NSLog(@"Test : %@", [[channelAffilationInfo allValues] filteredArrayUsingPredicate: predicate]);
	}
	
	return noOfAffiliations;
}



- (void)dealloc {
	
	TT_RELEASE_SAFELY(owner);
	TT_RELEASE_SAFELY(channelAffilationInfo);
	TT_RELEASE_SAFELY(geoCordinateInfo);
	
	[super dealloc];
}

@end


