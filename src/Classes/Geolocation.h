//
//  Location.h
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

// BC implementation of XEP-0080 (TODO)
@interface GeoLocation : NSObject {
	NSString *text;
	NSString *uri;
	NSString *locality;
	NSString *country;
}

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *uri;
@property(nonatomic, retain) NSString *locality;
@property(nonatomic, retain) NSString *country;

- (GeoLocation *)initFromXML:(NSXMLElement *)geolocElement;

- (BOOL)compare:(GeoLocation *)other;

@end
