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
#import "XMPPEngine.h"
#import "PostItem.h"
#import "TextFieldAlertView.h"
#import "Util.h"

@implementation PostsViewController
@synthesize node;

#pragma mark -
#pragma mark View lifecycle

- (PostsViewController *)initWithNode:(NSString *)_node andTitle:(NSString *)title
{
	[self tableView].backgroundColor = [UIColor colorWithRed:243.0/255.0 green:241.0/255.0 blue:229.0/255.0 alpha:1.0];
	[self tableView].separatorStyle = UITableViewCellSeparatorStyleNone;

	if (self = [super initWithNibName:@"PostsViewController" bundle: [NSBundle mainBundle]]) {
		[self setNode: _node];
		
		self.navigationItem.title = title;
		
		BuddycloudAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		followingData = [[appDelegate followingDataModel] retain];
		xmppEngine = [[appDelegate xmppEngine] retain];

		[followingData addDelegate: self];
		
		postedItems = [[NSMutableArray arrayWithArray: [followingData selectPostsForNode: node]] retain];
	}
	
	return self;
}

- (void)dealloc {
	[followingData removeDelegate: self];
	
	[postedItems release];
	[node release];
	
	[followingData release];
	[xmppEngine release];
	
    [super dealloc];
}

- (void)addTopic
{
	selectedEntryId = 0;
	
	TextFieldAlertView *followView = [[TextFieldAlertView alloc] initWithTitle: NSLocalizedString(@"New topic", @"")  
																	   message: NSLocalizedString(@"Your awesome topic post text", @"") 
																	  delegate: self 
															 cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
																 okButtonTitle:  NSLocalizedString(@"Post", @"")];
	
//	[[followView textField] setAutocapitalizationType: UITextAutocapitalizationTypeNone];
//	[[followView textField] setKeyboardType: UIKeyboardTypeASCIICapable];
	
	[followView show];
	[followView release];
}

- (void)addComment:(UIButton *)sender
{
	NSIndexPath *indexPath = [[self tableView] indexPathForCell: (UITableViewCell *)[[sender superview] superview]];
	PostItem *postItem = [postedItems objectAtIndex: indexPath.row];
	
	if (postItem) {	
		selectedEntryId = [postItem entryId];
		
		TextFieldAlertView *followView = [[TextFieldAlertView alloc] initWithTitle: NSLocalizedString(@"Your comment", @"")  
																		   message: NSLocalizedString(@"Comment on this post", @"") 
																		  delegate: self 
																 cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
																	 okButtonTitle:  NSLocalizedString(@"Comment", @"")];
		
		[followView show];
		[followView release];		
	}		
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex]) {
		// Post new topic to channel
		[xmppEngine postChannelText: [(TextFieldAlertView *)alertView enteredText] toNode: node inReplyTo: selectedEntryId];
	}
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
		
//			[[controller addCommentButton] addTarget: self action: @selector(addComment:) forControlEvents: UIControlEventTouchUpInside];
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
		
		}
		else {
			[[controller contentLabel] setText: [postItem content]];
		}
		[[controller contentLabel] setFont: [Util fontContent]];
		[[controller authorLabel] setFont: [Util fontLocationTime]];
		
		NSMutableString *sb = [NSMutableString stringWithString:@""];
		if ([postItem location] != nil) {
			[sb appendString:[postItem location]];
			[sb appendString:@" | "];
		}
		double ti = -(double)[postItem.postTime timeIntervalSinceNow];
		if (ti < 10) {
			[sb appendString:@"A few seconds ago"];
		} else if (ti < 60) {
			[sb appendString:@"Less than a minute ago"];
		} else if (ti < 60*60) {
			[sb appendFormat:@"%i minutes ago", (int)(ti / 60)];
		} else if (ti < 24*60*60) {
			[sb appendFormat:@"%i hours ago", (int)(ti / 3600)];
		} else if (ti < 7*24*60*60) {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"EEE 'at' HH:mm"];
			[sb appendString:[df stringFromDate:postItem.postTime]];
		} else if (ti < 365*24*60*60) {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"dd.MM HH:mm"];
			[sb appendString:[df stringFromDate:postItem.postTime]];
		} else {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"dd.MM.yy HH:mm"];
			[sb appendString:[df stringFromDate:postItem.postTime]];
		}
		[[controller authorLabel] setText: sb];
		
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
	
	int ret = 0;
	if ([postItem commentId] == 0) {
		CGSize maxSize = CGSizeMake([self view].bounds.size.width - 50, 1000);
		CGSize textSize = [[postItem content] sizeWithFont:[Util fontContent]
										 constrainedToSize:maxSize 
											 lineBreakMode:UILineBreakModeWordWrap];
		ret = textSize.height + 35;
		if (ret < 54) ret = 54;
	} else {
		CGSize maxSize = CGSizeMake([self view].bounds.size.width - 90, 1000);
		CGSize textSize = [[postItem content] sizeWithFont:[Util fontContent]
										 constrainedToSize:maxSize 
											 lineBreakMode:UILineBreakModeWordWrap];
		ret = textSize.height + 30;
		if (ret < 42) ret = 42;
	}
	
	return ret;
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
		for (int i = ([postedItems count] - 1); i >= 0; i--) {
			PostItem *storedPost = [postedItems objectAtIndex: i];
			
			if ([post entryId] < [storedPost entryId] || [post entryId] == [storedPost entryId]) {
				if ([post entryId] == [storedPost entryId]) {
					i++;
				}
				
				// Insert post into postedItems
				[postedItems insertObject: post atIndex: i];
				
				// Notify table that a cell needs inserting
				[[self tableView] insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow: i inSection: 0]] 
										withRowAnimation: ([post commentId] == 0 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight)];
				
				return;
			}
		}
		
		// Add post into postedItems
		[postedItems insertObject: post atIndex: 0];
		
		// Notify table that a cell needs inserting
		[[self tableView] insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow: 0 inSection: 0]] 
								withRowAnimation: ([post commentId] == 0 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight)];
	}
}



@end

