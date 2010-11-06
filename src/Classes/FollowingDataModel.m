//
//  FollowingDataModel.m
//  Buddycloud
//
//  Created by Ross Savage on 4/24/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingDataModel.h"
#import "FollowedItem.h"
#import "UserItem.h"
#import "PostItem.h"
#import "Events.h"

static sqlite3_stmt *insertPostStatement = nil;
static sqlite3_stmt *selectPostsForNodeStatement = nil;
static sqlite3_stmt *selectTopicPostStatement = nil;

@implementation FollowingDataModel

- (id)init
{
	if(self = [super initWithDatabaseName: @"following.sql"]) {
		followingData = [[NSMutableDictionary alloc] initWithCapacity: 1];
		
		multicastDelegate = [[MulticastDelegate alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[followingData release];	
	[multicastDelegate release];
	
	sqlite3_finalize(insertPostStatement);
	sqlite3_finalize(selectPostsForNodeStatement);
	sqlite3_finalize(selectTopicPostStatement);
	
	[super dealloc];
}

- (void)addDelegate:(id)delegate
{
	[multicastDelegate addDelegate: delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate: delegate];
}

- (void)prepareDatabaseForVersion:(int)majorVersion build:(int)minorVersion
{
	BOOL updatedDatabase = NO;
	
	NSLog(@"Following database version: %d.%d", majorVersion, minorVersion);
	if (majorVersion == 0 && minorVersion == 0) {
		// Update database to 0.1
		NSString *statement = @"CREATE TABLE posts (_key INTEGER PRIMARY KEY AUTOINCREMENT, node TEXT, entry_id INTEGER, comment_id INTEGER, post_time INTEGER, author_name TEXT, author_jid TEXT, author_affiliation INTEGER, location TEXT, content TEXT, is_read INTEGER DEFAULT 0, UNIQUE (entry_id, comment_id))";
		
		if ([self prepareAndExecuteSQL: statement] == SQLITE_DONE) {
			minorVersion = 1;
			updatedDatabase = YES;
		}
	}
	
/*	if (majorVersion == 0 && minorVersion == 1) {
		// Update database to 0.2
		NSString *statement = @"CREATE TABLE following (_key INTEGER PRIMARY KEY AUTOINCREMENT, priority INTEGER, last_update INTEGER, jid TEXT, node TEXT, title TEXT, description TEXT DEFAULT NULL, unread_msgs INTEGER DEFAULT 0, unread_posts INTEGER DEFAULT 0)";
		
		if ([self prepareAndExecuteSQL: statement] == SQLITE_DONE) {
			minorVersion = 2;
			updatedDatabase = YES;
		}
	}*/
		
	if (updatedDatabase) {
		// Update database version to latest
		[self setDatabaseToVersion: majorVersion build: minorVersion];
	}
}

- (BOOL)insertPost:(PostItem *)post
{
	BOOL result = NO;
	
	if ([post commentId] == 0 || [self doesTopicPostExist: [post entryId] forNode: [post node]]) {
		if (insertPostStatement == nil) {
			// Prepare the insert post statement
			const char *sql = "INSERT INTO posts (node, entry_id, comment_id, post_time, author_name, author_jid, author_affiliation, location, content, is_read) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			
			if (sqlite3_prepare_v2(db, sql, -1, &insertPostStatement, NULL) != SQLITE_OK) {
				NSLog(@"*** Error preparing insertPost statement: %s", sqlite3_errmsg(db));
				
				return result;
			}
		}
		
		sqlite3_bind_text(insertPostStatement, 1, [[post node] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int64(insertPostStatement, 2, [post entryId]);
		sqlite3_bind_int64(insertPostStatement, 3, [post commentId]);
		sqlite3_bind_int64(insertPostStatement, 4, [[post postTime] timeIntervalSince1970]);
		sqlite3_bind_text(insertPostStatement, 5, [[post authorName] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(insertPostStatement, 6, [[post authorJid] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(insertPostStatement, 7, [post authorAffiliation]);
		sqlite3_bind_text(insertPostStatement, 8, [[post location] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(insertPostStatement, 9, [[post content] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(insertPostStatement, 10, [post isRead]);
		
		if (sqlite3_step(insertPostStatement) == SQLITE_DONE) {
			result = YES;
			
			[multicastDelegate followingDataModel: self didInsertPost: post];
		}
		
		sqlite3_reset(insertPostStatement);
	}
	
	return result;
}

- (NSArray *)selectPostsForNode:(NSString *)node
{
	NSMutableArray *posts = [[NSMutableArray alloc] initWithCapacity: 0];
	
	if (selectPostsForNodeStatement == nil) {
		// Prepare the statement
		const char *sql = "SELECT entry_id, comment_id, post_time, author_jid, author_affiliation, location, content, is_read FROM posts WHERE node = ? ORDER BY entry_id DESC, comment_id ASC";
		
		if (sqlite3_prepare_v2(db, sql, -1, &selectPostsForNodeStatement, NULL) != SQLITE_OK) {
			NSLog(@"*** Error preparing selectPostsForNode statement: %s", sqlite3_errmsg(db));
			
			return posts;
		}
	}
	
	sqlite3_bind_text(selectPostsForNodeStatement, 1, [node UTF8String], -1, SQLITE_STATIC);
	
	while (sqlite3_step(selectPostsForNodeStatement) == SQLITE_ROW) {
		PostItem *post = [[PostItem alloc] initWithChannelNode: node];
		
		[post setEntryId: sqlite3_column_int64(selectPostsForNodeStatement, 0)];
		[post setCommentId: sqlite3_column_int64(selectPostsForNodeStatement, 1)];
		[post setPostTime: [NSDate dateWithTimeIntervalSince1970: sqlite3_column_int64(selectPostsForNodeStatement, 2)]];
		[post setAuthorJid: [DatabaseAccess stringFromUTF8ColumnText: sqlite3_column_text(selectPostsForNodeStatement, 3)]];
		[post setAuthorAffiliation: sqlite3_column_int(selectPostsForNodeStatement, 4)];
		[post setLocation: [DatabaseAccess stringFromUTF8ColumnText: sqlite3_column_text(selectPostsForNodeStatement, 5)]];
		[post setContent: [DatabaseAccess stringFromUTF8ColumnText: sqlite3_column_text(selectPostsForNodeStatement, 6)]];
		[post setIsRead: sqlite3_column_int(selectPostsForNodeStatement, 7)];
		
		[posts addObject: post];
	}
	
	sqlite3_reset(selectPostsForNodeStatement);
	
	return posts;
}

- (BOOL)doesTopicPostExist:(long long)entryId forNode:(NSString *)node
{
	BOOL result = NO;
	
	if (selectTopicPostStatement == nil) {
		// Prepare the statement
		const char *sql = "SELECT * FROM posts WHERE node = ? AND entry_id = ? AND comment_id = 0 LIMIT 1";
		
		if (sqlite3_prepare_v2(db, sql, -1, &selectTopicPostStatement, NULL) != SQLITE_OK) {
			NSLog(@"*** Error preparing selectTopicPostStatement statement: %s", sqlite3_errmsg(db));
			
			return result;
		}
	}
	
	sqlite3_bind_text(selectTopicPostStatement, 1, [node UTF8String], -1, SQLITE_STATIC);
	sqlite3_bind_int64(selectTopicPostStatement, 2, entryId);
	
	if (sqlite3_step(selectTopicPostStatement) == SQLITE_ROW) {
		result = YES;
	}
	
	sqlite3_reset(selectTopicPostStatement);
	
	return result;
}


- (ChannelItem *)getChannelItemForFollowedItem:(FollowedItem *)item
{
	ChannelItem *channelItem = nil;
	
	if(item) {
		if([item isKindOfClass: [UserItem class]]) {
			channelItem = [(UserItem *)item channel];
		}
		else {
			channelItem = (ChannelItem *)item;
		}
	}
	
	return channelItem;
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

- (void)followItem:(NSString *)item {
	
}

@end
