/* 
 DirectoryItem.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/22/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "DirectoryItem.h"

@implementation DirectoryItem

@synthesize directoryId, title, description;

- (void)dealloc
{
	[directoryId release];
	[title release];
	[description release];
	
	[super dealloc];
}

@end
