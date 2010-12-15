/* 
 XMPPInBandReg.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/10/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>
#import "XMPPModule.h"
#import "DDXML.h"
#import "AppConstants.h"

@class XMPPStream;
@class XMPPIQ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public XMPPInBandReg definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPInBandReg : XMPPModule {
	NSString *serverName;
	int iqIdCounter;
}

@property(readonly) NSString *serverName;

- (id)initWithStream:(XMPPStream *)xmppStream toServer:(NSString *)serverName;


- (void)queryRegistrationRequirementsForLegacyService;
- (void)registerLegacyService:(NSString *)service username:(NSString *)username password:(NSString *)password;
- (void)passwordChangeOnLegacyService:(NSString *)username newPassword:(NSString *)newPassword;
- (void)unregisterLegacyService;


//- (void)queryGatewayDiscoveryIdentityForLegacyService:(NSString *)service;
//- (void)queryGatewayAgentInfo;
//- (void)queryRegistrationRequirementsForLegacyService:(NSString *)service;
//- (void)registerLegacyService:(NSString *)service username:(NSString *)username password:(NSString *)password;
//- (void)unregisterLegacyService:(NSString *)service;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private XMPPInBandReg definition
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface XMPPInBandReg (PrivateAPI)

- (void)isRegistrationServiceEnabled:(XMPPIQ *)iq;
- (void)handleRegistrationResult:(XMPPIQ *)iq;


//
//- (void)handleNodeMetadataResult:(NSXMLElement *)xElement forNode:(NSString *)node;
//
//- (void)fetchAffiliationsForNode:(NSString *)node afterJid:(NSString *)jid;
//- (void)handleNodeAffiliationsResult:(XMPPIQ *)iq;
//
//- (void)handleChangeOfSubscriptionOrAffiliation:(NSXMLElement *)item;
//
//- (void)handleIncomingPubsubEvent:(NSXMLElement *)eventElement;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPInBandRegDelegate
@optional
- (void)xmppInBandReg:(XMPPInBandReg *)sender didRegistrationServiceExist:(UserAuthCodes)code;

- (void)xmppInBandReg:(XMPPInBandReg *)sender didUserRegister:(UserAuthCodes)code;
- (void)xmppInBandReg:(XMPPInBandReg *)sender didUserUnRegister:(UserAuthCodes)code;
- (void)xmppInBandReg:(XMPPInBandReg *)sender didUserPasswordChanged:(UserAuthCodes)code;

- (void)xmppInBandReg:(XMPPInBandReg *)sender didRecieveError:(UserAuthCodes)code;
@end