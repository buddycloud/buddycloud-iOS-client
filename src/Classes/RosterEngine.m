//
//  RosterEngine.m
//  Buddycloud
//
//  Created by Ross Savage on 4/7/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "RosterEngine.h"
#import "XMPPClient.h"
#import "Events.h"

@implementation RosterEngine

- (RosterEngine*) initWithXMPP:(XMPPClient*)client {
	[super init];
	xmpp = client;
	[xmpp addDelegate:self];
	return self;
}

- (void)xmppClientDidUpdateRoster: (XMPPClient*)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:[Events ROSTER_UPDATED] object:self];
}

- (NSArray *)sortedUsersByName {
	return [xmpp sortedUsersByName];
}

- (NSArray *)sortedUsersByAvailabilityName {
	return [xmpp sortedUsersByAvailabilityName];
}

- (NSArray *)sortedAvailableUsersByName {
	return [xmpp sortedAvailableUsersByName];
}

- (NSArray *)sortedUnavailableUsersByName {
	return [xmpp sortedUnavailableUsersByName];
}

- (NSArray *)unsortedUsers {
	return [xmpp unsortedUsers];
}

- (NSArray *)unsortedAvailableUsers {
	return [xmpp unsortedAvailableUsers];
}

- (NSArray *)unsortedUnavailableUsers {
	return [xmpp unsortedUnavailableUsers];
}



@end
