//
//  FollowingViewController.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowerCellController.h"
#import "FollowingDataModel.h"
#import "Events.h"
#import "UserItem.h"

@implementation FollowingViewController
@synthesize orderedKeys;
@synthesize followerCell;

- (id)initWithStyle:(UITableViewStyle)style andDataModel:(FollowingDataModel *)dataModel {
    if(self = [super initWithStyle:style]) {
		self.navigationItem.title = @"Following";
		
		followingList = [dataModel retain];
		[self setOrderedKeys: [followingList orderKeysByUpdated]];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onFollowingListUpdated)
													 name: [Events FOLLOWINGLIST_UPDATED]
												   object: nil];
	}
	
	return self;
}

- (void)viewDidLoad
{
	self.title = @"Following";
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[followingList release];
	[orderedKeys release];

    [super dealloc];
}

- (void)onFollowingListUpdated
{
	[self setOrderedKeys: [followingList orderKeysByUpdated]];

	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.orderedKeys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
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
	FollowedItem *item = [followingList getItemByKey: [orderedKeys objectAtIndex: indexPath.row]];
	
	if (item) {
		[[controller nameLabel] setText: [item title]];
		[[controller descriptionLabel] setText: [item description]];
		
		if ([item isKindOfClass: [UserItem class]]) {
			[[controller imageView] setImage: [UIImage imageNamed:@"contact.png"]];
		}
		else {
			[[controller imageView] setImage: [UIImage imageNamed:@"channel.png"]];
		}
		
		[controller release];
	}

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
	return 58.0f;
}

@end

