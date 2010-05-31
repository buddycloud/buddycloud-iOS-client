//
//  Location.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "Geolocation.h"
#import "NSXMLElementAdditions.h"

@implementation GeoLocation
@synthesize text, uri, locality, country;

- (GeoLocation *)initFromXML:(NSXMLElement *)geolocElement
{
	if(self = [super init]) {
		// TODO: Parse geoloc element
		[self setText: [[geolocElement elementForName: @"text"] stringValue]];
		[self setUri: [[geolocElement elementForName: @"uri"] stringValue]];
		[self setLocality: [[geolocElement elementForName: @"locality"] stringValue]];
		[self setCountry: [[geolocElement elementForName: @"country"] stringValue]];
	}
	
	return self;
}

- (void)dealloc
{
	[text release];
	[uri release];
	[locality release];
	[country release];
	
	[super dealloc];
}

- (BOOL)compare:(GeoLocation *)other
{
	if ([[self text] isEqualToString: [other text]]) {
		return YES;
	}
	
	return NO;
}

@end
