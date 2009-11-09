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

#import "BuddycloudAppDelegate.h"
#import "BuddyRequestDelegate.h"

#import "XMPPIQ.h"
#import "XMPPUser.h"
#import "XMPPClient.h"
#import "NSXMLElementAdditions.h"

extern XMPPClient *xmppClient;

NSString *features[] = {
	@"http://jabber.org/protocol/disco#info",
	@"http://jabber.org/protocol/geoloc",
	@"http://jabber.org/protocol/geoloc+notify",
	nil
};

@implementation BuddycloudAppDelegate
@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;
@synthesize followingTableView;
@synthesize placesTableView;
@synthesize channelsTableView;

- (void)applicationDidFinishLaunching: (UIApplication*)application
{
	[window addSubview: tabBarController.view];
	[[tabBarController.viewControllers objectAtIndex: 0]
	    setView: navigationController.view];
	
	places = [[NSArray arrayWithObjects: @"Place1",
					     @"Place2",
					     @"Place3", nil] retain];
	nearby = [[NSArray arrayWithObjects: @"Nearby1",
					     @"Nearby2",
					     @"Nearby3", nil] retain];
	channels = [[NSArray arrayWithObjects: @"Channel1",
					       @"Channel2",
					       @"Channel3", nil] retain];
	
	gotInitialPosition = NO;
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate: self];
	[locationManager startUpdatingLocation];
	
	wasAuthedBefore = NO;
	[xmppClient addDelegate: self];
	[xmppClient setDomain: @"cirrus.buddycloud.com"];
	[xmppClient setPort: 443];
	[xmppClient setMyJID: [XMPPJID jidWithUser: @"iphone2"
					    domain: @"buddycloud.com"
					  resource: @"buddycloud/iphone"]];
	[xmppClient setPassword: @"iphone"];
	[xmppClient setPriority: 10];
	[xmppClient setAllowsPlaintextAuth: NO];
	[xmppClient setAutoPresence: NO];
	[xmppClient connect];
}

- (void)xmppClientDidNotConnect: (XMPPClient*)sender
{
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle: @"Connection failed!"
		      message: @"The client could not connect to the "
			       @"Buddycloud server!"
		     delegate: self
	    cancelButtonTitle: @"OK"
	    otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)xmppClient: (XMPPClient*)sender
  didNotAuthenticate: (NSXMLElement*)error
{
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle: @"Authentication failed!"
		      message: @"The client could not authenticate with the"
			       @"Buddycloud server!"
		     delegate: self
	    cancelButtonTitle: @"OK"
	    otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)xmppClientDidDisconnect: (XMPPClient*)sender
{
	if (!wasAuthedBefore)
		return [self xmppClient: sender
		     didNotAuthenticate: nil];
}

- (void)xmppClientDidAuthenticate: (XMPPClient*)sender
{	
	NSXMLElement *pres, *caps;
	
	wasAuthedBefore = YES;

	pres = [NSXMLElement elementWithName: @"presence"];
	caps = [NSXMLElement elementWithName: @"c"
				       xmlns: @"http://jabber.org/protocol/caps"];
	[caps addAttributeWithName: @"node"
		       stringValue: @"http://buddycloud.com/iphone/caps"];
	[caps addAttributeWithName: @"ver"
		       stringValue: @"0.0.1-alpha"];
	[pres addChild: caps];
	[xmppClient sendElement: pres];
}

- (void)xmppClientDidUpdateRoster: (XMPPClient*)sender
{
	[followingTableView reloadData];
}

- (void)xmppClient: (XMPPClient*)sender
      didReceiveIQ: (XMPPIQ*)iq
{
	NSString *type = [[iq attributeForName: @"type"] stringValue];
	
	if ([type isEqualToString: @"get"]) {
		/* Ping */
		if ([iq elementForName: @"query"
				 xmlns: @"urn:xmpp:ping"])
			return [self sendPingReplyTo: [iq from]
				       withElementID: [iq elementID]];
		
		/* Version */
		if ([iq elementForName: @"query"
				 xmlns: @"jabber:iq:version"])
			return [self sendVersionReplyTo: [iq from]
					  withElementID: [iq elementID]];
		
		/* Disco */
		if ([iq elementForName: @"query"
				 xmlns: @"http://jabber.org/protocol/disco"
					@"#info"])
			return [self answerDisco: iq];
		
		/* If we're still here, we don't handle it */
		[self send501ForIQ: iq];
	} else if ([type isEqualToString: @"set"])
		[self send501ForIQ: iq];
	else if ([type isEqualToString: @"result"]) {
		/* Locationquery result */
		if ([iq elementForName: @"location"
				 xmlns: @"http://buddycloud.com/protocol/"
					@"location"])
			return;

		/* If we're still here, we don't handle it */
		[self send501ForIQ: iq];
	} else
		NSLog(@"WARNING: Received an IQ with invalid type!");	
}

-	(void)xmppClient: (XMPPClient*)sender
  didReceiveBuddyRequest: (XMPPJID*)jid
{
	NSString *msg = [NSString stringWithFormat:
	    @"The user %@ wants to follow you.\n"
	    @"Do you want to accept his/her request?", [jid bare]];
	BuddyRequestDelegate *delegate = [[BuddyRequestDelegate alloc]
	    initWithJID: jid];
	UIAlertView *alert = [[UIAlertView alloc]
		initWithTitle: @"Following request"
		      message: msg
		     delegate: delegate
	    cancelButtonTitle: nil
	    otherButtonTitles: @"Yes", @"No", nil];
	[alert show];
	[alert release];
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[super dealloc];
}

- (IBAction)addFriend: (id)sender
{
	if ([[sender title] isEqualToString: @"Add"])
		[sender setTitle: @"ddA"];
	else
		[sender setTitle: @"Add"];
}

- (void)searchBarSearchButtonClicked: (UISearchBar*)bar
{
	[bar resignFirstResponder];
}

-  (NSInteger)tableView: (UITableView*)tv
  numberOfRowsInSection: (NSInteger)section
{
	if ([tv isEqual: followingTableView])
		return [[xmppClient unsortedUsers] count];
	else if ([tv isEqual: placesTableView])
		return [places count];
	else if ([tv isEqual: channelsTableView])
		return [channels count];
	return 0;
}

- (UITableViewCell*)tableView: (UITableView*)tv
	cellForRowAtIndexPath: (NSIndexPath*)ipath
{
	NSString *identifier;
	UITableViewCell *cell;
	
	if ([tv isEqual: followingTableView])
		identifier = @"FriendCell";
	else if ([tv isEqual: placesTableView])
		identifier = @"PlaceCell";
	else if ([tv isEqual: channelsTableView])
		identifier = @"ChannelCell";
	else
		return nil;
	
	if ((cell = [tv dequeueReusableCellWithIdentifier: identifier]) == nil)
		cell = [[[UITableViewCell alloc]
		      initWithFrame: CGRectZero
		    reuseIdentifier: identifier] autorelease];
	
	if ([tv isEqual: followingTableView])
		cell.textLabel.text = [[[xmppClient sortedUsersByName]
		    objectAtIndex: ipath.row] displayName];
	else if ([tv isEqual: placesTableView])
		cell.textLabel.text = [places objectAtIndex: ipath.row];
	else if ([tv isEqual: channelsTableView])
		cell.textLabel.text = [channels objectAtIndex: ipath.row];	
	
	return cell;
}

- (void)send501ForIQ: (XMPPIQ*)iq
{
	NSXMLElement *error, *fni, *text;
	
	[iq removeAttributeForName: @"to"];
	[iq addAttributeWithName: @"to"
		     stringValue: [[iq attributeForName: @"from"] stringValue]];
	[iq removeAttributeForName: @"from"];
	[iq removeAttributeForName: @"type"];
	[iq addAttributeWithName: @"type"
		     stringValue: @"error"];
	
	error = [NSXMLElement elementWithName: @"error"];
	[error addAttributeWithName: @"code"
			stringValue: @"501"];
	[error addAttributeWithName: @"type"
			stringValue: @"cancel"];
	
	fni = [NSXMLElement elementWithName: @"feature-not-implemented"
				      xmlns: @"urn:ietf:params:xml:ns:"
					     @"xmpp-stanzas"];
	[error addChild: fni];
	
	text = [NSXMLElement elementWithName: @"text"
				 stringValue: @"The feature requested is not "
					      @"implemented by the recipient "
					      @"or server and therefore cannot "
					      @"be processed."];
	[text setXmlns: @"urn:ietf:params:xml:ns:xmpp-stanzas"];
	[error addChild: text];
	
	[iq addChild: error];
	
	[xmppClient sendElement: iq];
}

- (void)sendPingReplyTo: (XMPPJID*)jid
	  withElementID: (NSString*)elementId
{
	NSXMLElement *iq, *query;
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to"
		     stringValue: [jid full]];
	[iq addAttributeWithName: @"type"
		     stringValue: @"result"];
	if (elementId)
		[iq addAttributeWithName: @"id"
			     stringValue: elementId];
	
	query = [NSXMLElement elementWithName: @"query"
					xmlns: @"urn:xmpp:ping"];
	[iq addChild: query];
		
	[xmppClient sendElement: iq];
}

- (void)sendVersionReplyTo: (XMPPJID*)jid
	     withElementID: (NSString*)elementId
{
	NSXMLElement *iq, *query;
	UIDevice *device = [UIDevice currentDevice];
	NSMutableString *os = [NSMutableString stringWithCapacity: 0];
	[os appendString: [device systemName]];
	[os appendString: @" "];
	[os appendString: [device systemVersion]];
	[os appendString: @" @ "];
	[os appendString: [device model]];
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to"
		     stringValue: [jid full]];
	[iq addAttributeWithName: @"type"
		     stringValue: @"result"];
	if (elementId)
		[iq addAttributeWithName: @"id"
			     stringValue: elementId];
	
	query = [NSXMLElement elementWithName: @"query"
					xmlns: @"jabber:iq:version"];
	[query addChild: [NSXMLElement elementWithName: @"name"
					   stringValue: @"Buddycloud for "
							@"iPhone"]];
	[query addChild: [NSXMLElement elementWithName: @"version"
					   stringValue: @"0.0.1-alpha"]];
	[query addChild: [NSXMLElement elementWithName: @"os"
					   stringValue: os]];
	[iq addChild: query];
	
	[xmppClient sendElement: iq];
}

- (void)answerDisco: (XMPPIQ*)iq
{
	NSXMLElement *query, *identity, *feature;
	NSString **featureName;
	
	[iq removeAttributeForName: @"to"];
	[iq addAttributeWithName: @"to"
		     stringValue: [[iq attributeForName: @"from"] stringValue]];
	[iq removeAttributeForName: @"from"];
	[iq removeAttributeForName: @"type"];
	[iq addAttributeWithName: @"type"
		     stringValue: @"result"];
	
	query = [iq elementForName: @"query"
			     xmlns: @"http://jabber.org/protocol/disco#info"];
	identity = [NSXMLElement elementWithName: @"identity"];
	[identity addAttributeWithName: @"category"
			   stringValue: @"client"];
	[identity addAttributeWithName: @"type"
			   stringValue: @"mobile"];
	[query addChild: identity];
	
	// TODO: Check node
	
	for (featureName = features; *featureName != nil; featureName++) {
		feature = [NSXMLElement elementWithName: @"feature"];
		[feature addAttributeWithName: @"var"
				  stringValue: *featureName];
		[query addChild: feature];
	}
	
	[xmppClient sendElement: iq];
}

- (void)locationManager: (CLLocationManager*)manager
    didUpdateToLocation: (CLLocation*)location
           fromLocation: (CLLocation*)oldLocation
{
	if (gotInitialPosition)
		[self sendLocationFromLocationManager: manager
					   renewTimer: NO];
	else {
		gotInitialPosition = YES;
		[self sendLocationFromLocationManager: manager];
	}
}

- (void)sendLocationFromLocationManager: (CLLocationManager*)manager
{
	[self sendLocationFromLocationManager: manager
				   renewTimer: YES];
}

- (void)sendLocationFromLocationManager: (CLLocationManager*)manager
			     renewTimer: (BOOL)renew
{
	CLLocation *location;
	NSXMLElement *iq, *lq;
	NSString *lon, *lat, *accuracy;
	CLLocationCoordinate2D coordinate;
	static int loc_id = 0;
	SEL sel;
	
	if (![xmppClient isConnected])
		goto renew;
	
	location = [manager location];
	coordinate = [location coordinate];
	
	if (coordinate.longitude == NAN || coordinate.latitude == NAN ||
	    coordinate.longitude == 0 || coordinate.latitude == 0 ||
	    [location horizontalAccuracy] == 0)
		goto renew;
	
	lon = [NSString stringWithFormat: @"%f", coordinate.longitude];
	lat = [NSString stringWithFormat: @"%f", coordinate.latitude];
	accuracy = [NSString stringWithFormat: @"%f",
					       [location horizontalAccuracy]];
	
	iq = [NSXMLElement elementWithName: @"iq"];
	[iq addAttributeWithName: @"to"
		     stringValue: @"butler.buddycloud.com"];
	[iq addAttributeWithName: @"type"
		     stringValue: @"get"];
	[iq addAttributeWithName: @"id"
		     stringValue: [NSString stringWithFormat: @"location_%d",
							      loc_id++]];
	
	lq = [NSXMLElement elementWithName: @"locationquery"
				     xmlns: @"urn:xmpp:locationquery:0"];
	[lq addChild: [NSXMLElement elementWithName: @"lat"
					stringValue: lat]];
	[lq addChild: [NSXMLElement elementWithName: @"lon"
					stringValue: lon]];
	[lq addChild: [NSXMLElement elementWithName: @"accuracy"
					stringValue: accuracy]];
	[lq addChild: [NSXMLElement elementWithName: @"publish"
					stringValue: @"true"]];
	[iq addChild: lq];
	
	[xmppClient sendElement: iq];
	
renew:
	if (renew) {
		sel = @selector(sendLocationFromLocationManager:);
		[self performSelector: sel
			   withObject: manager
			   afterDelay: 120];
	}
}
@end
