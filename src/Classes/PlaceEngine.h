//
//  PlaceEngine.h
//  Buddycloud
//
//  Created by Ross Savage on 5/14/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class XMPPStream;
@class LocationEngine;

@interface PlaceEngine : NSObject {
	XMPPStream *xmppStream;
	LocationEngine* locationEngine;
	
	NSString *serverName;
	int iqIdCounter;
	
	int currentPlaceId;
	NSString *currentPlaceTitle;
	CLLocationCoordinate2D currentCoordinates;
}

@property(nonatomic, retain) XMPPStream *xmppStream;
@property(nonatomic, retain) NSString *serverName;
@property(nonatomic, retain) NSString *currentPlaceTitle;
@property(nonatomic) int currentPlaceId;
@property(nonatomic) CLLocationCoordinate2D currentCoordinates;

- (PlaceEngine *)initWithStream:(XMPPStream *)xmppStream toServer:(NSString *)serverName;

- (void)updateFutureLocationTo:(NSString *)placeText withPlaceId:(NSString *)placeId;

@end
