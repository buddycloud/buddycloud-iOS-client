/* 
 ChannelDetailInoDataSource.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/27/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "ChannelDetailInoDataSource.h"

#define POST_TOPIC_HEIGHT		90.0

@interface ChannelDetailInoDataSource (PrivateAPI)

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
@end 

@implementation ChannelDetailInoDataSource

@synthesize channelDetailItem, _tableView, nodeInfoDict = _nodeInfoDict;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNodeItem:(ChannelItem *)item {
	
	if (self = [super init]) {
		self.channelDetailItem = [[ChannelDetailItem alloc] init];
		[self.channelDetailItem setChannelItem: item];
		
		//Load the channel metadata.
		[self requestForChannelDetails];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(onChannelMetaDataUpdated:)
													 name: [Events CHANNEL_METADATA_ITEM_UPDATED]
												   object: nil];
	}
	
	return self;
}

/*
 *	Request for the channel details.
 */
- (void)requestForChannelDetails {
	if ([[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine].xmppStream isConnected]) {	
		[[[BuddycloudAppDelegate sharedAppDelegate] xmppEngine] fetechMetadataForNode: channelDetailItem.ident];
	}
}

/*
 * On Channel meta-data updated.
 */
- (void)onChannelMetaDataUpdated:(NSNotification *)notification
{
	NSLog(@"-------------onChannelMetaDataUpdated-------------");
	id item = [notification object];
	
	if (item && [_tableView.dataSource isKindOfClass: [ChannelDetailInoDataSource class]]) {
		if ([item isKindOfClass: [ChannelDetailItem class]]) {
			
			channelDetailItem = (ChannelDetailItem *)item;
		}
		else if ([item isKindOfClass: [NSMutableDictionary class]]) {
			
			NSMutableDictionary *affilations = (NSMutableDictionary *)item;
			[channelDetailItem setChannelAffilationInfo: affilations]; 
		}
	}
	
	[_tableView reloadData];
}


- (NSMutableDictionary *)getSectionItems:(ChannelDetailSections)section {
	
	NSMutableDictionary *items = nil;
	NSString *emptyString = @"";

	switch (section) {
			
		case CHANNEL_DETAIL_INFO:
			items = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																([channelDetailItem owner]) ? [channelDetailItem owner] : emptyString,
																[NSString stringWithFormat:@"%d moderators", [channelDetailItem getNoOfAffiliationByType: CHANAFF_MODERATOR]],
																[NSString stringWithFormat:@"%d followers", [channelDetailItem getNoOfAffiliationByType: CHANAFF_MEMBER]],
																@"no buddy is banned.",
																[NSString stringWithFormat:@"%d", [channelDetailItem rank]],
																nil]
													   forKeys:[NSArray arrayWithObjects:
																NSLocalizedString(@"Channel Producer", @""),
																NSLocalizedString(@"Channel Moderators", @""),
																NSLocalizedString(@"Channel Followers", @""),
																NSLocalizedString(@"Parsona", @""),
																NSLocalizedString(@"Channel Rank", @""),
																nil]];
			break;
			
		case CHANNEL_DETAIL_PRODUCER_OTPTIONS:
			items = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																[[[ButtonTableCell alloc] init] autorelease],
																[[[ToggleButtonTableCell alloc] init] autorelease],
																[[[ToggleButtonTableCell alloc] init] autorelease],
																nil]
													   forKeys:[NSArray arrayWithObjects:
																NSLocalizedString(@"Permanently Remove", @""),
																NSLocalizedString(@"Approve Followers", @""),
																NSLocalizedString(@"List Channel", @""),
																nil]];
			break;
			
		case CHANNEL_DETAIL_FOR_EVERYONE:
			items = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																[NSNumber numberWithInteger:[channelDetailItem getNoOfAffiliationByType: CHANAFF_MODERATOR]],
																[NSNumber numberWithInteger:[channelDetailItem getNoOfAffiliationByType: CHANAFF_MODERATOR]],
																[NSNumber numberWithInteger:[channelDetailItem getNoOfAffiliationByType: CHANAFF_MODERATOR]],
																nil]
													   forKeys:[NSArray arrayWithObjects:
																NSLocalizedString(@"Permanently Remove", @""),
																NSLocalizedString(@"Approve Followers", @""),
																NSLocalizedString(@"List Channel", @""),
																nil]];
			break;

		default:
			//NSLog(@"No section is defined!!");
			break;
	}
	 	
	return items;
}

#define CHANNEL_HEADER_HEIGHT		150

- (UIView *)getChannelInfoDetails {

	ChannelDetailHeader *channelDetailHeader = [[[ChannelDetailHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, CHANNEL_HEADER_HEIGHT)] autorelease];
	
	if (channelDetailHeader) {
		NSString *contentTxt = [NSString stringWithFormat:@"<b>%@</b>\n%@", channelDetailItem.title, channelDetailItem.description];
		NSString *statusTxt = [NSString stringWithFormat:@"%@", ((channelDetailItem.owner) ? channelDetailItem.owner : @"Your status : follows + posts")];
		
		channelDetailHeader.iconImage.image = [UIImage imageNamed: @"icon1.png"];
		[channelDetailHeader.contentLabel setText: [TTStyledText textFromXHTML:contentTxt lineBreaks:YES URLs:YES]];	
		[channelDetailHeader.statusLabel setText: [TTStyledText textFromXHTML:statusTxt lineBreaks:NO URLs:YES]];
		
		int ret = 0;
		CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 1000);
		CGSize contentTextSize = [contentTxt sizeWithFont:[Util fontContent]
										constrainedToSize:maxSize 
											lineBreakMode:UILineBreakModeWordWrap];
		
		CGSize statusTextSize = [statusTxt sizeWithFont:[Util fontLocationTime]
									   constrainedToSize:maxSize 
										   lineBreakMode:UILineBreakModeWordWrap];
		
		ret = contentTextSize.height + statusTextSize.height + 15.0;
		if (ret < (CHANNEL_AVATAR_HEIGHT + 10.0 * 2.0)) ret = (CHANNEL_AVATAR_HEIGHT + 10.0 * 2.0);
		
		channelDetailHeader.contentLabel.frame = CGRectMake(channelDetailHeader.contentLabel.frame.origin.x, channelDetailHeader.contentLabel.frame.origin.y, channelDetailHeader.contentLabel.frame.size.width, contentTextSize.height);
		channelDetailHeader.statusLabel.frame = CGRectMake(channelDetailHeader.contentLabel.frame.origin.x, channelDetailHeader.contentLabel.frame.size.height + 10.0, channelDetailHeader.contentLabel.frame.size.width, statusTextSize.height);
		channelDetailHeader.frame = CGRectMake(channelDetailHeader.frame.origin.x, 0.0, channelDetailHeader.frame.size.width, channelDetailHeader.contentLabel.frame.size.height + channelDetailHeader.statusLabel.frame.size.height + 10.0);
	}
	
	return channelDetailHeader;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [[self getSectionItems: section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	NSString *title = nil;
	
	switch (section) {
			
		case CHANNEL_DETAIL_INFO:
			break;

		case CHANNEL_DETAIL_PRODUCER_OTPTIONS:
			title = @"Producer Options";
			break;

		case CHANNEL_DETAIL_FOR_EVERYONE:
			title = [NSString stringWithFormat:@"%@'s Activity", (channelDetailItem.owner) ? channelDetailItem.owner : channelDetailItem.title];
			break;
//
//		case CHANNEL_DETAIL_LOOKUP:
//			title = @"Lookup";
//			break;

		default:
			//NSLog(@"No section is defined!!");
			break;
	}
	
	return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	int ret = 30;
	
	if (section == CHANNEL_DETAIL_INFO) { 
		NSString *contentTxt = [NSString stringWithFormat:@"<b>%@</b>\n%@", channelDetailItem.title, channelDetailItem.description];
		NSString *statusTxt = [NSString stringWithFormat:@"%@", @"Your status : follows + posts"];
		
		
		if (contentTxt) {
			CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 1000);
			CGSize contentTextSize = [contentTxt sizeWithFont:[Util fontContent]
											constrainedToSize:maxSize 
												lineBreakMode:UILineBreakModeWordWrap];
			
			CGSize statusTextSize = [statusTxt sizeWithFont:[Util fontLocationTime]
										  constrainedToSize:maxSize 
											  lineBreakMode:UILineBreakModeWordWrap];
			
			ret = contentTextSize.height + statusTextSize.height + 15.0;
			//NSLog(@"Post size: %f and geotime : %f", contentTextSize.height, statusTextSize.height);
			
			if (ret < (CHANNEL_AVATAR_HEIGHT + 10.0 * 2.0)) ret = (CHANNEL_AVATAR_HEIGHT + 10.0 * 2.0);
		} 
		else {
			ret = (CHANNEL_AVATAR_HEIGHT + 10.0 * 2.0);
		}
		
		//NSLog(@"RET: %d", ret);
	}
	
	return ret;	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section == CHANNEL_DETAIL_INFO) { 
		return [self getChannelInfoDetails];
	}
	
	return nil;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object
{
	if([object isKindOfClass:[ToggleButtonTableCell class]])
		return [ToggleButtonTableCell class];
	else if([object isKindOfClass:[ButtonTableCell class]])
		return [ButtonTableCell class];
	else if([object isKindOfClass:[NSNumber class]])
		return [CustomTableCellWithLeftTxt class];
	else
		return [UITableViewCell class];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *customCellIdentifier = @"customCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
	NSMutableDictionary *items = [self getSectionItems: indexPath.section];
	
	NSString *itemKey = [[items allKeys] objectAtIndex: indexPath.row];
	//NSLog(@"Key = %@ and value = %@", itemKey, [items valueForKey: itemKey]);
	
	@try { 
		if (cell == nil || ([cell class] != [self tableView:tableView cellClassForObject:[items valueForKey: itemKey]])) {
			if ([self tableView:tableView cellClassForObject:[items valueForKey: itemKey]] == [ToggleButtonTableCell class]) {
				cell = [[[ToggleButtonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier] autorelease];
			}
			else if ([self tableView:tableView cellClassForObject:[items valueForKey: itemKey]] == [ButtonTableCell class]) {
				cell = [[[ButtonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier] autorelease];
			}
			else if ([self tableView:tableView cellClassForObject:[items valueForKey: itemKey]] == [CustomTableCellWithLeftTxt class]) {
				cell = [[[CustomTableCellWithLeftTxt alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:customCellIdentifier] autorelease];
			}
			else {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:customCellIdentifier] autorelease];
			}
		}
		
		if ([cell isKindOfClass:[ToggleButtonTableCell class]]) {
			ToggleButtonTableCell *toggleButtonCell = (ToggleButtonTableCell *)cell;
			toggleButtonCell.textLabel.text = itemKey;
			
			return toggleButtonCell;
		}
		else if ([cell isKindOfClass:[ButtonTableCell class]]) {
			ButtonTableCell *buttonCell = (ButtonTableCell *)cell;
			buttonCell.textLabel.text = itemKey;
			buttonCell.delegate = self;
			[buttonCell.leftButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState: UIControlStateNormal];
			
			[buttonCell.leftButton setTag: BTN_ACTION_DELETE];
			
			return buttonCell;
		}
		else if ([cell isKindOfClass:[CustomTableCellWithLeftTxt class]]) {
			CustomTableCellWithLeftTxt *customCell = (CustomTableCellWithLeftTxt *)cell;
			customCell.textLabel.text = itemKey;
			customCell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[items valueForKey: itemKey] integerValue]];
			
			return customCell;
		}
		else if ([cell isKindOfClass:[UITableViewCell class]]) {
			cell.textLabel.text = itemKey;
			cell.detailTextLabel.text = [items valueForKey: itemKey];
		}
	}
	@catch (NSException *ex) {
		NSLog(@"Cell exception  = %@", [ex description]);
	}
	
	return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CustomizedTableCellDelegate - Methods.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)onButtonClick:(id)sender {
	UIButton *button = (UIButton *)sender;

	if (button.tag == BTN_ACTION_DELETE) {
		NSLog(@"Delete Action.... : %d", button.tag);	
	}
}


- (void) dealloc
{
	
	
	[super dealloc];
}

@end
