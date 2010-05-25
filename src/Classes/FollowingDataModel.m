//
//  FollowingDataModel.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingDataModel.h"
#import "FollowedItem.h"
#import "PostItem.h"
#import "Events.h"

static sqlite3_stmt *insertPostStatement = nil;

@implementation FollowingDataModel

- (id)init
{
	if(self = [super initWithDatabaseName: @"following.sql"]) {
		followingData = [[NSMutableDictionary alloc] initWithCapacity: 1];
	}
	
	return self;
}

// Clean up when we're done
- (void)dealloc
{
	[followingData removeAllObjects];
	followingData = nil;
	
	if (insertPostStatement) {
		sqlite3_finalize(insertPostStatement);
	}
	
	[super dealloc];
}

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion
{
	BOOL updatedDatabase = NO;
	
	NSLog(@"Following database version: %d.%d", majorVersion, minorVersion);
	
	if (majorVersion == 0 && minorVersion == 0) {
		// Update database to 0.1
		NSString *statement = @"CREATE TABLE following (_key INTEGER PRIMARY KEY AUTOINCREMENT, priority INTEGER, last_update INTEGER, jid TEXT, node TEXT, title TEXT, description TEXT DEFAULT NULL, unread_msgs INTEGER DEFAULT 0, unread_posts INTEGER DEFAULT 0)";
		
		if ([self prepareAndExecuteSQL: statement] == SQLITE_DONE) {
			minorVersion = 1;
			updatedDatabase = YES;
		}
	}
	
	if (majorVersion == 0 && minorVersion == 1) {
		// Update database to 0.2
		NSString *statement = @"CREATE TABLE posts (_key INTEGER PRIMARY KEY AUTOINCREMENT, node TEXT, entry_id INTEGER, comment_id INTEGER, post_time INTEGER, author_name TEXT, author_jid TEXT, author_affiliation INTEGER, location TEXT, content TEXT, is_read INTEGER DEFAULT 0, UNIQUE (entry_id, comment_id))";
		
		if ([self prepareAndExecuteSQL: statement] == SQLITE_DONE) {
			minorVersion = 2;
			updatedDatabase = YES;
		}
	}
	
	if (updatedDatabase) {
		// Update database version to latest
		[self setDatabaseToVersion: majorVersion build: minorVersion];
	}
}

- (BOOL)insertPost:(PostItem *)post
{
	BOOL result = NO;
	
	if (insertPostStatement == nil) {
		// Prepare the insert post statement
		const char *sql = "INSERT INTO posts (node, entry_id, comment_id, post_time, author_name, author_jid, author_affiliation, location, content, is_read) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		
		if (sqlite3_prepare_v2(db, sql, -1, &insertPostStatement, NULL) != SQLITE_OK) {
			NSLog(@"*** Error preparing post insert statement: %s", sqlite3_errmsg(db));
			
			return result;
		}
	}
	
	sqlite3_bind_text(insertPostStatement, 1, [[post node] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int64(insertPostStatement, 2, [post entryId]);
	sqlite3_bind_int64(insertPostStatement, 3, [post commentId]);
	sqlite3_bind_double(insertPostStatement, 4, [[post postTime] timeIntervalSince1970]);
	sqlite3_bind_text(insertPostStatement, 5, [[post authorName] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertPostStatement, 6, [[post authorJid] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertPostStatement, 7, [post authorAffiliation]);
	sqlite3_bind_text(insertPostStatement, 8, [[post location] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertPostStatement, 9, [[post content] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertPostStatement, 10, [post isRead]);
	
	if (sqlite3_step(insertPostStatement) == SQLITE_DONE) {
		result = YES;
	}
	
	sqlite3_reset(insertPostStatement);
	
	return result;
}



- (NSArray *)unorderedKeys
{
	return [followingData allKeys];
}

- (NSArray *)orderKeysByUpdated
{
	return [followingData keysSortedByValueUsingSelector:@selector(compareUpdate:)];
}

- (FollowedItem *)getItemByKey:(id)key
{
	return (FollowedItem *) [followingData objectForKey: key];
}

- (FollowedItem *)getItemByIdent:(NSString*)ident {
	for (id key in followingData) {
		FollowedItem *item = [followingData objectForKey: key];
		
		if ([item.ident isEqualToString:ident]) {
			return item;
		}
	}
	
	return nil;
}

@end
