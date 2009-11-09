/*
 * Copyright (C) 2009 Jonathan Schleifer.
 *
 * This file is part of the Buddycloud iPhone client.
 *
 * Buddycloud for iPhone is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; version 2 only.
 *
 * Buddycloud for iPhone is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with Buddycloud for iPhone. If not, see <http://www.gnu.org/licenses/>.
 */

#import "BuddyRequestFollowDelegate.h"
#import "XMPPClient.h"

extern XMPPClient *xmppClient;

@implementation BuddyRequestFollowDelegate
- initWithJID: (XMPPJID*)jid_
{
	if ((self = [super init]))
		jid = [jid_ retain];
	
	return self;
}

-      (void)alertView:(UIAlertView *)av
  clickedButtonAtIndex:(NSInteger)index
{
	if (index == 0)
		[xmppClient addBuddy: jid
			withNickname: nil];
	
	[self release];
}

- (void)dealloc
{
	[jid release];
	return [super dealloc];
}
@end
