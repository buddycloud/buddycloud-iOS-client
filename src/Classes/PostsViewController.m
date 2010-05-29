//
//  PostsViewController.m
//  Buddycloud
//
//  Created by Ross Savage on 5/26/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "PostsViewController.h"
#import "PostCellController.h"
#import "BuddycloudAppDelegate.h"
#import "FollowingDataModel.h"
#import "PostItem.h"

@implementation PostsViewController
@synthesize node;

#pragma mark -
#pragma mark View lifecycle

- (PostsViewController *)initWithNode:(NSString *)_node andTitle:(NSString *)title
{
	if (self = [super initWithNibName:@"PostsViewController" bundle: [NSBundle mainBundle]]) {
		[self setNode: _node];
		
		self.navigationItem.title = title;

		followingData = [[(BuddycloudAppDelegate *) [[UIApplication sharedApplication] delegate] followingDataModel] retain];
		[followingData addDelegate: self];
		
		postedItems = [[NSMutableArray arrayWithArray: [followingData selectPostsForNode: node]] retain];
	}
	
	return self;
}

- (void)dealloc {
	[followingData removeDelegate: self];
	[followingData release];
	
	[node release];
	[postedItems release];
	
    [super dealloc];
}

- (void)addTopic
{
}

- (void)addComment:(id)sender
{
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Add post topic button
	UIBarButtonItem *topicButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose 
																			   target: self 
																			   action: @selector(addTopic)];
	
	self.navigationItem.rightBarButtonItem = topicButton;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [postedItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	PostItem *postItem = [postedItems objectAtIndex: indexPath.row];
	
	if (postItem) {	
		PostCellController *controller;
		
		if ([postItem commentId] == 0) {
			// Topic
			controller = [[PostTopicCellController alloc] initWithNibName: @"PostTopicCell" bundle: [NSBundle mainBundle]];
		
			[[controller addCommentButton] setTag: [postItem entryId]];
		}
		else {
			// Comment
			controller = [[PostCellController alloc] initWithNibName: @"PostCommentCell" bundle: [NSBundle mainBundle]];
		}
		
		// Set table cell
		cell = (UITableViewCell *)controller.view;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		if ([[postItem content] hasPrefix: @"/me "]) {
			[[controller contentLabel] setText: [[postItem content] 
												 stringByReplacingOccurrencesOfString: @"/me" 
												 withString: [[postItem authorJid] substringToIndex: [[postItem authorJid] rangeOfString: @"@"].location]]];
		
			[[controller contentLabel] setFont: [UIFont fontWithName: @"Helvetica-Oblique" size: 12.0f]];
		}
		else {
			[[controller contentLabel] setText: [postItem content]];
		}
		
		[[controller authorLabel] setText: [postItem authorJid]];
		
		[controller release];
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PostItem *postItem = [postedItems objectAtIndex: indexPath.row];
	
	if ([postItem commentId] != 0) {
		return 52.0f;
	}
	
	return 64.0f;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark FollowingDataModel delegate implementation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)followingDataModel:(FollowingDataModel *)model didInsertPost:(PostItem *)post
{
	// Handle insertion of new post
	if ([node isEqualToString: [post node]]) {
		for (int i = 0; i < [postedItems count]; i++) {
			PostItem *storedPost = [postedItems objectAtIndex: i];
			
			if ([post entryId] > [storedPost entryId] || [post entryId] == [storedPost entryId]) {
				while ([post entryId] == [storedPost entryId]) {
					// Find insertion index for comment
					i++;
					
					storedPost = [postedItems objectAtIndex: i];
				}
				
				// Insert post into postedItems
				[postedItems insertObject: post atIndex: i];
				
				// Notify table that a cell needs inserting
				[[self tableView] insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow: i inSection: 0]] 
										withRowAnimation: ([post commentId] == 0 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight)];
				
				break;
			}
		}
	}
}



@end

