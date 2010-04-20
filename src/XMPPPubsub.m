//
//  XMPPPubsub.m
//  Buddycloud
//
//  Created by Ross Savage on 4/20/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "XMPPPubsub.h"
#import "XMPPClient.h"

@implementation XMPPPubsub

- (id)initWithXMPPClient:(XMPPClient *)xmppClient delegate:(id)aDelegate
{
	if((self = [super init]))
	{
		delegate = aDelegate;
	
		client = [xmppClient retain];
		[client addDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	[server release];
	
	[client removeDelegate:self];
	[client release];
	
	[super dealloc];
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

- (NSString *)pubsubServer
{
	return server;
}

- (void)setPubsubServer:(NSString *)aServer
{
	if (![server isEqual:aServer]) {
		[server release];
		server = [aServer copy];
	}
}

@end
