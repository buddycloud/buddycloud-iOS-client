/*
 * Copyright (c) 2009, Jonathan Schleifer <js@webkeks.org>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice is present in all copies.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#import "BuddyRequestDelegate.h"
#import "BuddyRequestFollowDelegate.h"
#import "XMPPClient.h"

extern XMPPClient *xmppClient;

@implementation BuddyRequestDelegate
- initWithJID: (XMPPJID*)jid_
{
	if ((self = [super init]))
		jid = [jid_ retain];
	
	return self;
}

-      (void)alertView:(UIAlertView *)av
  clickedButtonAtIndex:(NSInteger)index
{
	if (index == 0) {
		[xmppClient acceptBuddyRequest: jid];

		NSString *msg = [NSString stringWithFormat:
		    @"Do you want to follow %@ as well?", jid.bare];
		BuddyRequestFollowDelegate *delegate =
		    [[BuddyRequestFollowDelegate alloc] initWithJID: jid];
		UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle: @"Follow this person?"
			      message: msg
			     delegate: delegate
		    cancelButtonTitle: nil
		    otherButtonTitles: @"Yes", @"No", nil];
		[alert show];
		[alert release];
	} else if (index == 1)
		[xmppClient rejectBuddyRequest: jid];
	
	[self release];
}

- (void)dealloc
{
	[jid release];
	return [super dealloc];
}
@end
