//
//  LocationEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "LocationEngine.h"
#import "XMPPClient.h"
#import "NSXMLElementAdditions.h"

@implementation LocationEngine

- (LocationEngine*) initWithXMPP:(XMPPClient*)client {
	[super init];
	
	xmpp = client;
	locMgr = [[CLLocationManager alloc] init];
	[locMgr setDelegate: self];
	[locMgr startUpdatingLocation];
	
	return self;
}

- (void) dealloc {
	[super dealloc];
	[locMgr stopUpdatingLocation];
	[locMgr release];
}

- (void)locationManager: (CLLocationManager*)manager
    didUpdateToLocation: (CLLocation*)location
           fromLocation: (CLLocation*)oldLocation
{
	if (gotInitialPosition)
		[self sendLocationFromLocationManager: manager
								   renewTimer: NO];
	else {
		gotInitialPosition = YES;
		[self sendLocationFromLocationManager: manager];
	}
}

- (void)sendLocationFromLocationManager: (CLLocationManager*)manager
{
	[self sendLocationFromLocationManager: manager renewTimer: YES];
}

- (void)sendLocationFromLocationManager: (CLLocationManager*)manager 
							 renewTimer: (BOOL)renew
{
	CLLocation *location;
	NSXMLElement *iq, *locationquery;
	NSString *lon, *lat, *accuracy;
	CLLocationCoordinate2D coordinate;
	SEL sel;
	
	if (![xmpp isConnected])
		goto renew; // Wtf? :O
	
	location = [manager location];
	coordinate = [location coordinate];
	
	if (coordinate.longitude == NAN || coordinate.latitude == NAN ||
	    coordinate.longitude == 0 || coordinate.latitude == 0 ||
	    [location horizontalAccuracy] == 0)
		goto renew;
	
	lon = [NSString stringWithFormat: @"%f", coordinate.longitude];
	lat = [NSString stringWithFormat: @"%f", coordinate.latitude];
	accuracy = [NSString stringWithFormat: @"%f", [location horizontalAccuracy]];
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to" stringValue: @"butler.buddycloud.com"];
	[iq addAttributeWithName: @"type" stringValue: @"get"];
	[iq addAttributeWithName: @"id" stringValue: @"location1"];
	
	locationquery = [NSXMLElement elementWithName: @"locationquery" xmlns: @"urn:xmpp:locationquery:0"];
	[locationquery addChild: [NSXMLElement elementWithName: @"lat" stringValue: lat]];
	[locationquery addChild: [NSXMLElement elementWithName: @"lon" stringValue: lon]];
	[locationquery addChild: [NSXMLElement elementWithName: @"accuracy" stringValue: accuracy]];
	[locationquery addChild: [NSXMLElement elementWithName: @"publish" stringValue: @"true"]];
	
	[iq addChild: locationquery];
	[xmpp sendElement: iq];
	
renew:
	if (renew) {
		sel = @selector(sendLocationFromLocationManager:);
		[self performSelector: sel
				   withObject: manager
				   afterDelay: 120];
	}
}

@end
