//
//  PlaceEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 5/14/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "PlaceEngine.h"
#import "PlacesDataModel.h"
#import "LocationEngine.h"
#import "XMPPStream.h"
#import "NSXMLElementAdditions.h"
#import "Events.h"

typedef enum {
	kIqId_setNextLocation = 256,
	kIqId_locationQuery
} placeIQIdTypes;

@implementation PlaceEngine
@synthesize xmppStream;
@synthesize serverName;
@synthesize currentPlaceId, currentPlaceTitle, currentCoordinates;

- (PlaceEngine *) initWithStream:(XMPPStream *)aXmppStream toServer:(NSString *)aServerName {
	if (self = [super init]) {
		[self setServerName: aServerName];
		
		dataModel = [[PlacesDataModel alloc] init];
		
		// Initialize LocationEngine
		locationEngine = [[LocationEngine alloc] initWithDelegate: self];
		
		// Initialize XMPPStream
		xmppStream = aXmppStream;
		[xmppStream addDelegate: self];
		
		// Add observer to future location arrival
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onFutureLocationArrival:)
													 name: [Events ARRIVED_AT_FUTURE_LOCATION]
												   object: nil];
	}
	
	return self;
}

- (void) dealloc {
	[xmppStream removeDelegate: self];

	[serverName release];
	[locationEngine release];	
	[currentPlaceTitle release];
	
	[dataModel release];
	
	[super dealloc];
}

- (void)onFutureLocationArrival:(id)object
{
	[self setFutureGeolocationText: @"" withPlaceId: nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public PlaceEngine Place Setting
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setCurrentGeolocationById:(NSString *)placeId
{
}

- (void)setFutureGeolocationText:(NSString *)text withPlaceId:(NSString *)placeId
{
	// Update future location
	// http://buddycloud.com/cms/node/103#place_next
	
	// Build place element
	NSXMLElement *placeElement = [NSXMLElement elementWithName: @"place"];
	[placeElement addChild: [NSXMLElement elementWithName: @"text" stringValue: text]];
	
	if (placeId) {
		[placeElement addChild: [NSXMLElement elementWithName: @"id" stringValue: placeId]];		
	}
	
	// Build query result element
	NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"http://buddycloud.com/protocol/place#next"];
	[queryElement addChild: placeElement];
	
	// Build version IQ result
	NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
	[iqStanza addAttributeWithName: @"to" stringValue: serverName];
	[iqStanza addAttributeWithName: @"type" stringValue: @"set"];
	[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"%d:%d", kIqId_setNextLocation, iqIdCounter++]];
	[iqStanza addChild: queryElement];
	
	[xmppStream sendElement: iqStanza];	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender
{
	// XMPPStream has disconnected
	[locationEngine stopReceivingLocation];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	// XMPPStream has authenticated connection
	[locationEngine startReceivingLocation];
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
			
			if (![newPlaceLabel isEqualToString: currentPlaceTitle]) {
				[self setCurrentPlaceTitle: newPlaceLabel];
				
				// Notification of location update
				[[NSNotificationCenter defaultCenter] postNotificationName:[Events LOCATION_CHANGED] object:self];
			}
			
			return YES;
		}
	}
	
	return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LocationEngine Delegates
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)LocationEngine:(LocationEngine *)sender didReceiveLocation:(CLLocation *)location
{
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
			[iqStanza addAttributeWithName: @"to" stringValue: serverName];
			[iqStanza addAttributeWithName: @"type" stringValue: @"get"];
			[iqStanza addAttributeWithName: @"id" stringValue: [NSString stringWithFormat: @"%d:%d", kIqId_locationQuery, iqIdCounter++]];
			[iqStanza addChild: locationElement];
			
			[xmppStream sendElement: iqStanza];
		}
	}
}


@end
