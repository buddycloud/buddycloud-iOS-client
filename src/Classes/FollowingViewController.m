//
//  FollowingViewController.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingViewController.h"
#import "Events.h"
#import "RosterEngine.h"
#import "FollowerCellController.h"
#import "XMPPUser.h"

@implementation FollowingViewController
@synthesize followerCell;

- (id)initWithStyle:(UITableViewStyle)style {
    [super initWithStyle:style];
	self.navigationItem.title = @"Following";
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onRosterUpdated:)
												 name:[Events ROSTER_UPDATED]
											   object:nil];
	following = [[NSMutableArray alloc] init];
    return self;
}

- (void) viewDidLoad
{
	self.title = @"Following";
}

- (void)dealloc {
    [super dealloc];
	[following release];
}

- (void) onRosterUpdated:(id)sender {
	NSNotification *nn = (NSNotification*)sender;
	RosterEngine *roster = (RosterEngine*)[nn object];
	[following removeAllObjects];
	[following addObjectsFromArray:[roster sortedUsersByName]];
	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [following count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Dequeue or create a new cell
	//    static NSString *CellIdentifier = @"Cell";
	//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//    if (cell == nil) {	
	
	FollowerCellController *controller = [[FollowerCellController alloc] initWithNibName:@"FollowerCell" bundle:[NSBundle mainBundle]];
	UITableViewCell *cell = (UITableViewCell *)controller.view;
	//		NSLog(@"Cell %@", cell); 
	//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//    }
    
	// Set up this specific cell's content
    XMPPUser *user = [following objectAtIndex:indexPath.row];
	[[controller nameLabel] setText:[user displayName]];
	[[controller imageView] setImage:[UIImage imageNamed:@"defaultImage.png"]];
	[controller release];
	// Outta here
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	return 64.0f;
}

@end

