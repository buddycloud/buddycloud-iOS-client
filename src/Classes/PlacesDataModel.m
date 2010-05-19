//
//  PlacesDataModel.m
//  Buddycloud
//
//  Created by Ross Savage on 5/18/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "PlacesDataModel.h"

@implementation PlacesDataModel

- (id)init
{
	if(self = [super initWithDatabaseName: @"places.sql"]) {
		
	}
	
	return self;
}

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion
{
	NSLog(@"Places database version: %d.%d", majorVersion, minorVersion);
	
	if (majorVersion == 0 && minorVersion < 1) {
		// Update database to 0.1
		
		// TODO: create places table
	}
	
	// Update database version to latest
//	[self setDatabaseToVersion: 0 build: 1];
}

@end
