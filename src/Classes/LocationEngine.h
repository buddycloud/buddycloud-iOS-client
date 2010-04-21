//
//  LocationEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class XMPPClient;

@interface LocationEngine : NSObject <CLLocationManagerDelegate> {
	XMPPClient *xmppClient;
	CLLocationManager *locationManager;
	
	NSTimer *timer;
	
	int currentPlaceId;
	NSString *currentPlaceTitle;
	CLLocationCoordinate2D currentCoordinates;
}

@property(readonly) int currentPlaceId;
@property(readonly) NSString *currentPlaceTitle;
@property(readonly) CLLocationCoordinate2D currentCoordinates;

- (void)sendLocationUpdate:(CLLocation *)location;

@end
