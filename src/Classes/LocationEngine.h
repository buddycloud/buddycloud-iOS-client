//
//  LocationEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class XMPPStream;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public LocationEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface LocationEngine : NSObject <CLLocationManagerDelegate> {
	XMPPStream *xmppStream;
	CLLocationManager *locationManager;
	
	NSTimer *timer;
	
	int currentPlaceId;
	NSString *currentPlaceTitle;
	CLLocationCoordinate2D currentCoordinates;
}

@property(readonly) int currentPlaceId;
@property(readonly) NSString *currentPlaceTitle;
@property(readonly) CLLocationCoordinate2D currentCoordinates;

- (LocationEngine*) initWithStream:(XMPPStream *)xmppStream;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private LocationEngine definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface LocationEngine (PrivateAPI)

- (void)sendLocationUpdate:(CLLocation *)location;

@end