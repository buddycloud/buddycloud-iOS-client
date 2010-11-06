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

#import <QuartzCore/QuartzCore.h>

@implementation PostsViewController
@synthesize node;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNode:(NSString* )_node query:(NSDictionary*)query {

	if (self = [self initWithNode:_node andTitle:[query valueForKey:@"title"]]) {
		
	}
	
	return self; 
}

- (id)initWithNode:(NSString *)_node andTitle:(NSString *)title
{
	[self tableView].backgroundColor = [UIColor colorWithRed:243.0/255.0 green:241.0/255.0 blue:229.0/255.0 alpha:1.0];
	[self tableView].separatorStyle = UITableViewCellSeparatorStyleNone;

	if (self = [super initWithNibName:@"PostsViewController" bundle: [NSBundle mainBundle]]) {
		self.navigationItem.title = title;
		[self setNode: _node];
		
		followingData = [[[BuddycloudAppDelegate sharedAppDelegate] followingDataModel] retain];
		xmppEngine = [[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine] retain];

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view data source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [postedItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	PostItem *postItem = [postedItems objectAtIndex: indexPath.row];
	
	if (postItem) {	
		PostCellController *controller;

		// Is this a topic or a comment6 cell?
		if ([postItem commentId] == 0) {
			controller = [[PostTopicCellController alloc] initWithNibName: @"PostTopicCell" bundle: [NSBundle mainBundle]];
		} else {
			controller = [[PostCellController alloc] initWithNibName: @"PostCommentCell" bundle: [NSBundle mainBundle]];
		}
		
		// Set table cell
		cell = (UITableViewCell *)controller.view;
		cell.accessoryType = UITableViewCellAccessoryNone;
		if ([postItem commentId] != 0) {
			controller.contentContainer.layer.cornerRadius = 4;
		}
		
		// Add basic content
		if ([[postItem content] hasPrefix: @"/me "]) {
			[[controller contentLabel] setText: [[postItem content] 
												 stringByReplacingOccurrencesOfString: @"/me" 
												 withString: [[postItem authorJid] substringToIndex: [[postItem authorJid] rangeOfString: @"@"].location]]];
		
		} else {
			[[controller contentLabel] setText: [postItem content]];
		}
		[[controller contentLabel] setFont: [Util fontContent]];
		[[controller authorLabel] setFont: [Util fontLocationTime]];
		
		// Add location and time
		if ([postItem location] != nil) {
			[[controller authorLabel] setText: [NSString stringWithFormat:@"%@ | %@", [postItem location], [Util getPrettyDate:[postItem postTime]]]];
		} else {
			[[controller authorLabel] setText: [NSString stringWithFormat:@"%@", [Util getPrettyDate:[postItem postTime]]]];
		}
		
		[controller release];
	}
	
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Table view delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Cell sizes depend on the content length.
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memory management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

