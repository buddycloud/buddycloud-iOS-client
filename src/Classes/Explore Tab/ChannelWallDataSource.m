/* 
 ChannelWallDataSource.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "ChannelWallDataSource.h"

#define POST_TOPIC_HEIGHT		90.0

@interface ChannelWallDataSource (PrivateAPI)

- (NSMutableArray *)getTopicItems;
- (NSMutableArray *)getTopicComments:(PostItem *)topicItem; 

@end

@implementation ChannelWallDataSource

@synthesize _postedItems, _tableView, _node;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPostItems:(NSMutableArray *)items withNode:(NSString *)node {
	if (self = [super init]) {
		_postedItems = items;
		_node = node;

//		_postedItems =[[NSMutableArray alloc] initWithObjects:
//					  [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:@"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", nil] forKey:@"Text should wrap nicely. Text is always in the color of its buddy color palette. Which looks black but is really a secret blend of bck dark blue."],
//					  [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", nil] forKey:@"Text should wrap nicely. Text is always in the color of its buddy color palette."],
//					  [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:@"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", nil] forKey:@"Text should wrap nicely. Text is always in the "],
//					  [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:@"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", nil] forKey:@"Text should wrap nicely. Text is always in the color of its buddy color palette. Which looks black but is really a secret blend of bck dark blue."],
//					  [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:@"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", @"hey wassup !!!!", nil] forKey:@"Text should wrap nicely. Text is always in the color of its buddy color palette. Which looks black but is really a secret blend of bck dark blue."],
//					  nil];
		
		NSLog(@"Posted items: %@", _postedItems);
	}
	
	return self;
}

- (NSMutableArray *)getTopicItems {
	
	NSMutableArray *sortedtTopicsArray = nil;
	long commentId = 0;
	
	if (_postedItems) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"commentId == %d", commentId]];
		NSArray *topicItems = [_postedItems filteredArrayUsingPredicate: predicate];
		
		//sort with posted time.
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"postTime" ascending:YES] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		sortedtTopicsArray = (NSMutableArray *)[topicItems sortedArrayUsingDescriptors:sortDescriptors];
	}
	
	return sortedtTopicsArray;
}

- (NSMutableArray *)getTopicComments:(PostItem *)topicItem {
	
	NSMutableArray *sortedtTopicCommentsArray = nil;
	
	if (_postedItems && topicItem) {
		NSLog(@"comment id = %lld and entr id = %lld", topicItem.commentId, topicItem.entryId);
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(entryId == %lld) AND (commentId != %lld)", topicItem.entryId, topicItem.commentId];
		NSArray *commentItem = [_postedItems filteredArrayUsingPredicate: predicate];
		
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"postTime" ascending:YES] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		sortedtTopicCommentsArray = (NSMutableArray *)[commentItem sortedArrayUsingDescriptors:sortDescriptors];
		
		//NSLog(@"Comments : %@", [sortedtTopicCommentsArray valueForKeyPath: @"content"]);
	}
	
	return sortedtTopicCommentsArray;
}


- (UIView *)getTopicCellView:(NSInteger)section {
	
	ChannelTopicCell *topicHeader = [[[ChannelTopicCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:nil] autorelease];
	NSArray *topicItems = [self getTopicItems];
	
	if ([topicItems count] > 0) {
		PostItem *topicItem = [topicItems objectAtIndex: section];
		topicHeader.postItem = topicItem;
	
		CGFloat topicRowHeight = [ChannelTopicCell tableView:self._tableView rowHeightForObject:topicItem];
		topicHeader.frame = CGRectMake(topicHeader.frame.origin.x, 0.0, topicHeader.frame.size.width, topicRowHeight);
		
		if ([[self getTopicComments: topicItem] count] > 0) {
			topicHeader.rowShadowImage.hidden = NO;
		}
	}

	return topicHeader;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//NSLog(@"Scrolling..... ");	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSArray *topicItems = [self getTopicItems];
	
	if ([topicItems count] > 0) {
		PostItem *topicItem = [topicItems objectAtIndex: section];
		return [[self getTopicComments: topicItem] count];
	}

	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self getTopicItems] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	NSArray *topicItems = [self getTopicItems];
	if ([topicItems count] > 0) {
		PostItem *topicItem = [topicItems objectAtIndex: section];
		return [ChannelTopicCell tableView:tableView rowHeightForObject:topicItem];
	}
	
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSArray *topicItems = [self getTopicItems];
	
	if ([topicItems count] > 0) {
		PostItem *topicItem = [topicItems objectAtIndex: indexPath.section];
		return [ChannelTopicCell tableView:tableView rowHeightForObject: [[self getTopicComments: topicItem] objectAtIndex: indexPath.row]];
	}
	
	return 0.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [self getTopicCellView:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    ChannelCommentCell *commentCell = (ChannelCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	if (commentCell == nil) {
        commentCell = [[[ChannelCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		commentCell.selectionStyle = UITableViewCellSeparatorStyleSingleLine;
	}
	
	NSArray *topicItems = [self getTopicItems];
	
	if ([topicItems count] > 0) {
		PostItem *topicItem = [topicItems objectAtIndex: section];
		PostItem *commentItem = ([[self getTopicComments: topicItem] count] > 0) ? [[self getTopicComments: topicItem] objectAtIndex: row] : nil;
		
		if (commentItem)
			commentCell.postItem = commentItem;

	}
	
	return commentCell;
}
- (void) dealloc
{
	TT_RELEASE_SAFELY(_postedItems);
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark FollowingDataModel delegate implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)followingDataModel:(FollowingDataModel *)model didInsertPost:(PostItem *)post
{
	// Handle insertion of new post
	if ([_node isEqualToString: [post node]]) {

		//Find the section, if it's post comment.
		if (post.commentId == 0) {
			NSInteger indexTopicObj = [[self getTopicItems] count] + 1;

			[self._postedItems addObject: post];
			[[self _tableView] insertSections:[NSIndexSet indexSetWithIndex:indexTopicObj] 
							 withRowAnimation:UITableViewRowAnimationLeft];
		}
		else {
			NSInteger indexTopicObj = [[[self getTopicItems] valueForKeyPath:@"entryId"] indexOfObject:(NSInteger)post.entryId];
			
			if (indexTopicObj != NSNotFound) {
				PostItem *topicItem = [[self getTopicItems] objectAtIndex: indexTopicObj];
				NSInteger indexLastCommentObj = [[self getTopicComments: topicItem] count] + 1;

				[self._postedItems addObject: post];
				[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject: [NSIndexPath indexPathForRow:indexLastCommentObj inSection: indexTopicObj]] 
										 withRowAnimation:UITableViewRowAnimationRight];
				
			}
		}
	}
}
@end
