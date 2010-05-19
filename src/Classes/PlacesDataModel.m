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

@end
