/* 
 XMPPInBandReg.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/10/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */


#import "XMPPInBandReg.h"
#import "XMPP.h"



@implementation XMPPInBandReg

@synthesize serverName;

- (id)initWithStream:(XMPPStream *)aXmppStream toServer:(NSString *)aServerName
{
	if ((self = [super initWithStream:aXmppStream]))
	{
  		serverName = [aServerName retain];
	}
	
	return self;
}


- (void)dealloc
{
	[xmppStream release];
	[serverName release];
	
	[super dealloc];
}

/**
 * Registration process
 * @see: http://xmpp.org/extensions/xep-0077.html#usecases-register
 **/
- (void)queryRegistrationRequirementsForLegacyService 
{
	//<iq type='get' id='reg1'>
	//	<query xmlns='jabber:iq:register'/>
	//</iq>
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"id" stringValue:@"reg1"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addChild:query];

	[xmppStream sendElement:iq];
}

- (void)registerLegacyService:(NSString *)service username:(NSString *)username password:(NSString *)password
{
	//<iq type='set' id='reg2'>
	//	<query xmlns='jabber:iq:register'>
    //		<username>bill</username>
    //		<password>Calliope</password>
    //		<email>bard@shakespeare.lit</email>
	//	</query>
	//</iq>
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
	[query addChild:[NSXMLElement elementWithName:@"username" stringValue:username]];
	[query addChild:[NSXMLElement elementWithName:@"password" stringValue:password]];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"set"];
	[iq addAttributeWithName:@"id" stringValue:@"reg2"];
	[iq addChild:query];
	
	[xmppStream sendElement:iq];
}

/**
 * Password Change process
 * @see: http://xmpp.org/extensions/xep-0077.html#usecases-changepw
 **/
- (void)passwordChangeOnLegacyService:(NSString *)username newPassword:(NSString *)newPassword
{
	//<iq type='set' to='shakespeare.lit' id='change1'>
	//	<query xmlns='jabber:iq:register'>
    //		<username>bill</username>
    //		<password>newpass</password>
	//	</query>
	//</iq>
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
	[query addChild:[NSXMLElement elementWithName:@"username" stringValue:username]];
	[query addChild:[NSXMLElement elementWithName:@"password" stringValue:newPassword]];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"set"];
	[iq addAttributeWithName:@"to" stringValue:serverName];
	[iq addAttributeWithName:@"id" stringValue:@"change1"];
	[iq addChild:query];
	
	[xmppStream sendElement:iq];
}

/**
 * Unregistration process
 * @see: http://xmpp.org/extensions/xep-0077.html#registrar-querytypes-unregister
 **/
- (void)unregisterLegacyService
{
	//<iq to='marlowe.shakespeare.lit' type='get'>
	//	<query xmlns='jabber:iq:register'>
    //		<remove/>
	//	</query>
	//</iq>
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
	[query addChild:[NSXMLElement elementWithName:@"remove"]];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addAttributeWithName:@"id" stringValue:@"unreg1"];
	[iq addChild:query];
	
	[xmppStream sendElement:iq];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"Recieve IQ....");		
	
	BOOL result = NO;
	
	if ([[[iq attributeForName: @"from"] stringValue] isEqualToString: serverName]) {
		NSString *iqType = [[iq attributeForName: @"type"] stringValue];
		
		result = YES;
		
		if([iqType isEqualToString: @"result"] || [iqType isEqualToString: @"error"]) {
			// Process IQ result
			NSString *iqIdData = [[iq attributeForName: @"id"] stringValue];
			
			if ([iqIdData isEqualToString:@"reg1"]) {
				[self isRegistrationServiceEnabled:iq];
			}
			else if ([iqIdData isEqualToString:@"reg2"]) {
				[self handleRegistrationResult:iq];
			}
			else if ([iqIdData isEqualToString:@"change1"]) {
				
			}
			else if ([iqIdData isEqualToString:@"unreg1"]) {
				
			}
		}
	}
	
	return result;
}


- (void)isRegistrationServiceEnabled:(XMPPIQ *)iq 
{
	NSString *iqType = [[iq attributeForName: @"type"] stringValue];
	NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
	
	if ([iqType isEqualToString: @"result"]) {
		
		[multicastDelegate xmppInBandReg:self didRegistrationServiceExist: kreg_success];
	}
	else if ([iqType isEqualToString: @"error"]) {
		
		[multicastDelegate xmppInBandReg:self didRecieveError: kreg_unknwonError];
	}
}
	
	
- (void)handleRegistrationResult:(XMPPIQ *)iq 
{
	NSString *iqType = [[iq attributeForName: @"type"] stringValue];
	NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
	
	if ([iqType isEqualToString: @"result"]) {
		NSString *alreadyRegistered = [[queryElement elementForName: @"registered"] stringValue];
		
		if (!alreadyRegistered && [[[iq attributeForName: @"id"] stringValue] isEqualToString: @"reg2"]) {
			//successfully registered.
			[multicastDelegate xmppInBandReg:self didUserRegister: kreg_success];
		}
		else {
			//user already registered.
			[multicastDelegate xmppInBandReg:self didRecieveError: kreg_userAlreadyRegError];
		}
	}
	else if ([iqType isEqualToString: @"error"]) {
		NSXMLElement *errorElement = [iq elementForName: @"error"];
		NSInteger errorCode = ([[errorElement attributeForName: @"code"] stringValue]) ? [[[errorElement attributeForName: @"code"] stringValue] integerValue] : kreg_unknwonError;
		
		[multicastDelegate xmppInBandReg:self didRecieveError:errorCode];
	}
}
	
@end