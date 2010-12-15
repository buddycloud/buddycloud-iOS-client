//
//  LocationEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "LocationEngine.h"

@implementation LocationEngine

- (LocationEngine *)initWithLocDelegate:(id)aDelegate
{
	if (self =[super init]) {	
		delegate = aDelegate;
		
		// Initialize location manager
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate: self];
	}
	
	return self;
}

- (void)dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	if ([timer isValid]) {
		[timer release];
	}
	
	[super dealloc];
}

- (void)startReceivingLocation
{
	// Start location updates
	[self handleLocationUpdate];
	
	[locationManager startUpdatingLocation];
}

- (void)stopReceivingLocation
{
	// Stop location updates
	//[timer invalidate];	//TODO: Need to check why the stop recieving event is triggered more than once!
	
	[locationManager stopUpdatingLocation];	
}

- (void)handleLocationUpdate
{
	[self handleLocationUpdateWithLocation: [locationManager location]];
}

- (void)handleLocationUpdateWithLocation:(CLLocation *)location
{
	// Stop current timer
	timer = nil;
	
	// Send location update
	[delegate LocationEngine: self didReceiveLocation: location];
	
	// Reset timer
	timer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(handleLocationUpdate) userInfo:nil repeats:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)location fromLocation:(CLLocation *)oldLocation
{
	[self handleLocationUpdateWithLocation: location];
}

@end
