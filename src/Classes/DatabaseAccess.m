//
//  DatabaseAccess.m
//  Buddycloud
//
//  Created by Ross Savage on 5/18/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "DatabaseAccess.h"

@implementation DatabaseAccess
@dynamic dbVersion;

- (id)initWithDatabaseName:(NSString *)fileName
{
	if(self = [super init]) {
		NSString* databasePath = [self dbFilePathFromName: fileName];
		
		// Check and create database
		if ([self checkAndCreateDatabase: databasePath]) {
			// Open database
			if (sqlite3_open([databasePath UTF8String], &db) != SQLITE_OK) {
				// Failed to open database
				sqlite3_close(db);
				db = nil;
				
				NSLog(@"*** Database %@ failed to open", fileName);
			}
		}
	}
	
	return self;
}

- (void)dealloc
{
	sqlite3_close(db);
	
	[super dealloc];
}

- (int)dbVersion
{
	
	return dbVersion;
}

- (void)setDbVersion:(int)version
{
	dbVersion = version;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public DatabaseAccess methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isDatabaseOpen
{
	return (db != nil);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private DatabaseAccess methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)dbFilePathFromName:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex: 0];
	
	return [documentsDir stringByAppendingPathComponent: fileName];
}

- (BOOL)checkAndCreateDatabase:(NSString *)databasePath
{
	BOOL result = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (!(result = [fileManager fileExistsAtPath: databasePath])) {
		// Database file does not yet exist
		NSString *databaseResourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"database.sql"];
		
		result = [fileManager copyItemAtPath: databaseResourcePath toPath: databasePath error: nil];
	}
	
	return result;
}

@end
