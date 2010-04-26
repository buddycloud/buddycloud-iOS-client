//
//  LocationEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "LocationEngine.h"
#import "XMPPStream.h"
#import "NSXMLElementAdditions.h"
#import "Events.h"

@implementation LocationEngine
@synthesize currentPlaceId;
@synthesize currentPlaceTitle;
@synthesize currentCoordinates;

- (LocationEngine*) initWithStream:(XMPPStream *)aXmppStream {
	[super init];
	
	// Initialize location manager
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate: self];
	
	// Initialize XMPPStream
	xmppStream = aXmppStream;
	[xmppStream addDelegate: self];
	
	return self;
}

- (void) dealloc {
	[xmppStream removeDelegate:self];
	
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[currentPlaceTitle release];
	
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)location fromLocation:(CLLocation *)oldLocation
{
	[self sendLocationUpdate: location];
}

- (void)sendLocationUpdate:(CLLocation *)location
{
	// Stop current timer
	[timer invalidate];
	timer = nil;
	
	// Send location update
	if (location) {
		currentCoordinates = [location coordinate];
		
		if (currentCoordinates.longitude != NAN && currentCoordinates.latitude != NAN && 
			(currentCoordinates.longitude != 0 || currentCoordinates.latitude != 0))
		{
			NSString *longitude = [NSString stringWithFormat: @"%f", currentCoordinates.longitude];
			NSString *latitude = [NSString stringWithFormat: @"%f", currentCoordinates.latitude];
			NSString *accuracy = [NSString stringWithFormat: @"%f", [location horizontalAccuracy]];
			
			NSXMLElement *locationElement = [NSXMLElement elementWithName: @"locationquery" xmlns: @"urn:xmpp:locationquery:0"];
			[locationElement addAttributeWithName: @"clientver" stringValue: @"iPhone/1.0"];
			[locationElement addChild: [NSXMLElement elementWithName: @"lat" stringValue: latitude]];
			[locationElement addChild: [NSXMLElement elementWithName: @"lon" stringValue: longitude]];
			[locationElement addChild: [NSXMLElement elementWithName: @"accuracy" stringValue: accuracy]];
			[locationElement addChild: [NSXMLElement elementWithName: @"publish" stringValue: @"true"]];
			
			NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
			[iqStanza addAttributeWithName: @"to" stringValue: @"butler.buddycloud.com"];
			[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
			[iqStanza addAttributeWithName: @"id" stringValue: @"location1"];
			[iqStanza addChild: locationElement];
			
			[xmppStream sendElement: iqStanza];
		}
	}
	
	// Reset timer
	timer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(forceLocationUpdate) userInfo:nil repeats:NO];
}

- (void)forceLocationUpdate
{
	// Send location update
	[self sendLocationUpdate: [locationManager location]];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender
{
	// XMPPStream has disconnected
	[timer invalidate];
	
	// Stop location updates
	[locationManager stopUpdatingLocation];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	// XMPPStream has authenticated connection
	[self forceLocationUpdate];
	
	// Start location updates
	[locationManager startUpdatingLocation];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSString *iqType = [[iq attributeForName: @"type"] stringValue];
	
	if ([iqType isEqualToString: @"result"]) {
		// Location query result
		NSXMLElement *locationElement = [iq elementForName: @"location" xmlns: @"http://buddycloud.com/protocol/location"];
		
		if (locationElement) {
			// Update place data
			NSString *newPlaceLabel = [[locationElement attributeForName: @"label"] stringValue];
			
			currentPlaceId = [[[locationElement attributeForName: @"placeid"] stringValue] intValue];
			
			if (![newPlaceLabel isEqualToString:currentPlaceTitle]) {
				[currentPlaceTitle release];
				currentPlaceTitle = [newPlaceLabel retain];
				
				// Notification of location update
				[[NSNotificationCenter defaultCenter] postNotificationName:[Events LOCATION_CHANGED] object:self];
			}
		}
		
		return YES;
	}
	
	return NO;
}


@end
