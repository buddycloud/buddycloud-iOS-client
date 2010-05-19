//
//  DatabaseAccess.m
//  Buddycloud
//
//  Created by Ross Savage on 5/18/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "DatabaseAccess.h"

static sqlite3_stmt *updateVersionStatement = nil;

@implementation DatabaseAccess

- (id)initWithDatabaseName:(NSString *)fileName
{
	if(self = [super init]) {
		NSString* databasePath = [self dbFilePathFromName: fileName];
		
		// Check and create database
		if ([self checkAndCreateDatabase: databasePath]) {
			// Open database
			if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
				// Get database version
				const char *sql = "SELECT major, minor FROM version LIMIT 1";
				sqlite3_stmt *versionStatement;
				
				if (sqlite3_prepare_v2(db, sql, -1, &versionStatement, NULL) == SQLITE_OK) {
					if (sqlite3_step(versionStatement) == SQLITE_ROW) {
						// Prepare delegate for database version
						[self prepareDatabaseForVersion: sqlite3_column_int(versionStatement, 0) 
												  build: sqlite3_column_int(versionStatement, 1)];
					}
				}
				
				sqlite3_finalize(versionStatement);
			}
			else {
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
	
	if (updateVersionStatement) {
		sqlite3_finalize(updateVersionStatement);
	}
	
	[super dealloc];
}

- (void)setDatabaseToVersion:(int)majorVersion build:(int)minorVersion
{
	if (updateVersionStatement == nil) {
		// Prepare the version update statement
		const char *sql = "UPDATE version SET major = ?, minor = ?";
		
		if (sqlite3_prepare_v2(db, sql, -1, &updateVersionStatement, NULL) != SQLITE_OK) {
			NSLog(@"*** Error preparing version update statement");
			
			return;
		}
	}
	
	sqlite3_bind_int(updateVersionStatement, 1, majorVersion);
	sqlite3_bind_int(updateVersionStatement, 2, minorVersion);
	
	if (sqlite3_step(updateVersionStatement) != SQLITE_DONE) {
		NSLog(@"Error while updating: %s", sqlite3_errmsg(db));
	
		sqlite3_reset(updateVersionStatement);
		
		return;
	}
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
		
		NSLog(@"*** Creating database: %@", databasePath);
		
		result = [fileManager copyItemAtPath: databaseResourcePath toPath: databasePath error: nil];
	}
	
	return result;
}

@end
