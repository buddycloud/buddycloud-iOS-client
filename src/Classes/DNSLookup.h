//
//  DNSLookup.h
//  Buddycloud
//
//  Created by Deminem on 12/15/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DNSLookupDelegate;

@interface  DNSLookupResult : NSObject
{
	NSString *domainName;
	NSInteger priority;
	NSInteger weight;
	NSInteger port;
}

@property (nonatomic, retain) NSString *domainName;
@property (nonatomic) NSInteger priority;
@property (nonatomic) NSInteger weight;
@property (nonatomic) NSInteger port;

@end



@interface DNSLookup : NSObject {
	
	NSMutableArray *_resultsArr;
	
}

@property (nonatomic, retain) NSMutableArray *_resultsArr;

- (void)queryServiceNameDNSLookUp;
- (void)updateResult:(DNSLookupResult *)result;

@end
