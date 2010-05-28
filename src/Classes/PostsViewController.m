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
		postedItems = [[NSMutableArray arrayWithArray: [followingData selectPostsForNode: node]] retain];
	}
	
	return self;
}

- (void)dealloc {
	[followingData release];
	[node release];
	[postedItems release];
	
    [super dealloc];
}

- (void)addComment:(id)sender
{
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// self.navigationItem.title = node;

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
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
		}
		else {
			// Comment
			controller = [[PostCellController alloc] initWithNibName: @"PostCommentCell" bundle: [NSBundle mainBundle]];
		}
		
		// Set table cell
		cell = (UITableViewCell *)controller.view;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		[[controller contentLabel] setText: [postItem content]];
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



@end

