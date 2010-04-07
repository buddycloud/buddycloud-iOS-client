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
	XMPPClient *xmpp;
	CLLocationManager *locMgr;
	bool gotInitialPosition;
}

- (void)sendLocationFromLocationManager: (CLLocationManager*)manager;
- (void)sendLocationFromLocationManager: (CLLocationManager*)manager
							 renewTimer: (BOOL)renew;

@end
