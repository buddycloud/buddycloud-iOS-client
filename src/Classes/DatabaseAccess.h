//
//  DatabaseAccess.h
//  Buddycloud
//
//  Created by Ross Savage on 5/18/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@protocol DatabaseAccessDelegate
@optional

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public DatabaseAccess definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface DatabaseAccess : NSObject <DatabaseAccessDelegate> {
	sqlite3 *db;
}

- (id)initWithDatabaseName:(NSString *)fileName;

- (BOOL)isDatabaseOpen;
- (void)setDatabaseToVersion:(int)majorVersion build:(int)minorVersion;

- (int)prepareAndExecuteSQL:(NSString *)statement;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private DatabaseAccess definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface DatabaseAccess (PrivateAPI)

+ (void)removeDatabase;
- (NSString *)dbFilePathFromName:(NSString *)fileName;
- (BOOL)checkAndCreateDatabase:(NSString *)databasePath;

+ (NSString *)stringFromUTF8ColumnText:(const unsigned char *)text;

@end
