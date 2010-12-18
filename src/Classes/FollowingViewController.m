//
//  FollowingViewController.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowerCellController.h"
#import "ChannelCellController.h"
#import "FollowingDataModel.h"
#import "Events.h"
#import "UserItem.h"
#import "ChannelItem.h"
#import "TextFieldAlertView.h"
#import "PostsViewController.h"

@implementation FollowingViewController
@synthesize orderedKeys;
@synthesize followerCell, channelCell;

- (id)initWithStyle:(UITableViewStyle)style andDataModel:(FollowingDataModel *)dataModel {
    if(self = [super initWithStyle:style]) {

		followingList = [dataModel retain];
		[self setOrderedKeys: [followingList orderKeysByUpdated]];
		
		[[TTNavigator navigator].URLMap from:kcreateNewAcctURLPath
					   toModalViewController:[BuddycloudAppDelegate sharedAppDelegate] selector:@selector(createNewAccount)];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onFollowingListUpdated)
													 name: [Events FOLLOWINGLIST_UPDATED]
												   object: nil];
	}
	
	return self;
}

- (void)viewDidLoad
{	
	[super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated {
	
	
}

- (void)dealloc
{
	[[TTNavigator navigator].URLMap removeURL:kcreateNewAcctURLPath];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[followingList release];
	[orderedKeys release];

    [super dealloc];
}

- (void)onAddButton
{
	UIAlertView *alertView = nil;
	
	//Check if user trying to add the topic with default BC user, then show an alert to please register urself.
	XMPPEngine *xmppEngine = (XMPPEngine *)[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine];
	
	//Before disconnect, check if it's not the same username through which it's already login.
	if(![[[xmppEngine.xmppStream myJID] domain] isEqualToString:[NSString stringWithFormat:@"%@", klogin_BuddycloudNetwork]])
	{
		alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(alertPrompt, @"")
												message:NSLocalizedString(registerToFollowNewChannel, @"")
											   delegate:self
									  cancelButtonTitle:NSLocalizedString(cancelBtnLabel, @"")
									  otherButtonTitles:NSLocalizedString(registerBtnLabel, @""), nil] autorelease];
		[alertView show];
		
		return;
	}
	
	TextFieldAlertView *followView = [[TextFieldAlertView alloc] initWithTitle: NSLocalizedString(@"Add following", @"")  
																	   message: NSLocalizedString(@"Enter Jabber or #Channel ID", @"") 
																	  delegate: self 
															 cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
															 okButtonTitle:  NSLocalizedString(@"Follow", @"")];
	
	[[followView textField] setAutocapitalizationType: UITextAutocapitalizationTypeNone];
	[[followView textField] setKeyboardType: UIKeyboardTypeASCIICapable];
	
	[followView show];
	[followView release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex]) {
		
		if ([alertView.message isEqualToString:NSLocalizedString(registerToFollowNewChannel, @"")]) {
			//Push the user to register screen.
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:kcreateNewAcctURLPath]];
		}
		else {
			// User adds an item to follow
			[followingList followItem: [(TextFieldAlertView *)alertView enteredText]];
		}
	}
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
	return [orderedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	FollowedItem *item = [followingList getItemByKey: [orderedKeys objectAtIndex: indexPath.row]];
	
	if (item) {
		if ([item isKindOfClass: [UserItem class]]) {
			FollowerCellController *controller = [[FollowerCellController alloc] initWithNibName:@"FollowerCell" bundle:[NSBundle mainBundle]];
			
			// Set cell data
			UserItem *userItem = (UserItem *)item;
			
			// Set table cell
			cell = (UITableViewCell *)controller.view;
			
			if ([userItem channel]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
				
			[[controller titleLabel] setText: [userItem title]];
			
			// Adjust & set description
			if ([[userItem description] length] > 0) {
				CGRect descriptionFrame = [[controller descriptionLabel] frame];
				CGSize descriptionSize = [[userItem description] sizeWithFont: [[controller descriptionLabel] font] 
											   constrainedToSize: descriptionFrame.size
												   lineBreakMode: [[controller descriptionLabel] lineBreakMode]];
				
				descriptionFrame.size.height = descriptionSize.height;
				
				if ([[[userItem geoPrevious] text] length] == 0 || [[[userItem geoFuture] text] length] == 0) {
					descriptionFrame.origin.y -= [[[controller descriptionLabel] font] xHeight];
				}
				
				[[controller descriptionLabel] setFrame: descriptionFrame];
			}
			
			[[controller descriptionLabel] setText: [userItem description]];
			
			// Set geolocation labels
			[[controller geoPreviousLabel] setText: [[userItem geoPrevious] text]];
			[[controller geoCurrentLabel] setText: [[userItem geoCurrent] text]];
			[[controller geoFutureLabel] setText: [[userItem geoFuture] text]];

			if ([[[userItem geoPrevious] text] length] == 0) {
				// If there is no previous set, adjust curent & future frames
				[[controller geoFutureLabel] setFrame: [[controller geoCurrentLabel] frame]];
				[[controller geoCurrentLabel] setFrame: [[controller geoPreviousLabel] frame]];
			}
				
			//}
			
			//if ([userItem geoFuture]) {
			//}
			
			[controller release];			
		}
		else if ([item isKindOfClass: [ChannelItem class]]) {
			ChannelCellController *controller = [[ChannelCellController alloc] initWithNibName:@"TopicCell" bundle:[NSBundle mainBundle]];
			
			// Set table cell
			cell = (UITableViewCell *)controller.view;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			// Set cell data
			ChannelItem *channelItem = (ChannelItem *)item;
			
			[[controller titleLabel] setText: [channelItem title]];
			[[controller rankLabel] setText: [NSString stringWithFormat: @"%@: %d", NSLocalizedString(@"Rank", @""), [channelItem rank]]];
			[[controller descriptionLabel] setText: [channelItem description]];
			
			[controller release];			
		}
	}		
	
    // Dequeue or create a new cell
	//    static NSString *CellIdentifier = @"Cell";
	//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//    if (cell == nil) {		
	//		NSLog(@"Cell %@", cell); 
	//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	//    }

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	FollowedItem *item = [followingList getItemByKey: [orderedKeys objectAtIndex: indexPath.row]];
	ChannelItem *channel = [followingList getChannelItemForFollowedItem: item];
	
	if (channel) {
		//NSLog(@"Channel : %@ and title = %@", [channel ident], [item title]);
		NSLog(@"URL : %@",[NSString stringWithFormat:kPostWithNodeAndTitleURLPath, [channel ident], [item title]] );
		
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:kPostWithNodeAndTitleURLPath, [channel ident], [item title]]] 
								 applyAnimated:YES]];
	}
	else {
		[tableView deselectRowAtIndexPath: indexPath animated: YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 64.0f;
	
	FollowedItem *item = [followingList getItemByKey: [orderedKeys objectAtIndex: indexPath.row]];
	
	if (item && [item isKindOfClass: [UserItem class]]) {
		UserItem *userItem = (UserItem *)item;
		
		if ([[userItem description] length] > 0) {
			UIFont *font = [UIFont fontWithName: @"Helvetica" size: 12];
			CGSize descriptionSize = [[userItem description] sizeWithFont: font 
														constrainedToSize: CGSizeMake(tableView.bounds.size.width - 18, 30)
															lineBreakMode: UILineBreakModeTailTruncation];
			
			if ([[[userItem geoPrevious] text] length] == 0 || [[[userItem geoFuture] text] length] == 0) {
				result -= [font xHeight];
			}
			
			result += (descriptionSize.height + [font xHeight]);
		}
	}
	
	return ((result < 64.0f) ? 64.0f : result);
}

@end

