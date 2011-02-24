/* 
 AppConstans.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */


#import <Foundation/Foundation.h>

#define TABLE_DISPLAY_HEIGHT	150

#define errorMsgView_tag	999
#define errorLabel_tag		998
		
#define klogin_GmailNetwork				@"gmail.com"
#define klogin_LiveJournalNetwork		@"livejournal.com"
#define klogin_GmxNetwork				@"gmx.com"
#define klogin_JabberNetwork			@"jabber.com"
#define klogin_BuddycloudNetwork		@"buddycloud.com"
#define klogin_AnonBCNetwork			@"anon.buddycloud.com"

typedef enum {
	kreg_unknwonError				= 0,
	kreg_success					= 1,
	kreg_userAlreadyRegError		= 2,
	kreg_userAuthenticationError	= 3,
	kreg_badRequestError			= 400,
	kreg_notAllowedError			= 405,	
	kreg_infoMissingError			= 406,
	kreg_userNameConflictError		= 409 
		
} UserAuthCodes;

@interface AppConstants

extern NSString * const applicationVersion;
extern NSString * const appIntroVedioUrl;

//************************** BUDDY CLOUD ENGINE SETTINGS **************************//

//**** XMPP ENGINE SETTINGS ****//
extern NSString * const XMPP_BC_DOMAIN; 
extern NSString * const XMPP_BC_IPHONE_RESOURCE; 

extern NSString	* const XMPP_ENGINE_SERVER;
extern NSInteger const XMPP_ENGINE_SERVER_PORT;

extern NSString * const XMPP_ANONYMOUS_DEFAULT_JID;


extern NSString * const XMPP_PUBSUB_SERVER;

//**** PLACE ENGINE SETTINGS ****//
extern NSString * const PLACE_ENGINE_SERVER;

//************************** BUDDY CLOUD ENGINE SETTINGS END **************************//



//************************** ATLAS APP URLS **************************//
extern NSString * kAppRootURLPath;
extern NSString * kTabBarURLPath;
extern NSString * kTabBarItemURLPath;
extern NSString * kMenuPageURLPath;

extern NSString * kloginServicesWithTitleURLPath;

extern NSString * kloginURLPath;
extern NSString * kloginWithNetworkIDURLPath;

extern NSString * kloginPrefilledURLPath; 
extern NSString * kloginPrefilledWithNetworkIDURLPath;

extern NSString * kcreateNewAcctURLPath;

extern NSString * kexploreChannelsURLPath;
extern NSString * kexploreChannelsWithTitleAndUsernameURLPath; 

//************************** ATLAS APP URLS END **************************//


//************************** UI CONSTANTS **************************//

//************************** UI CONSTANTS END **************************//


//************************** LOCALIZABLE CONSTANTS **************************//
extern NSString * authenticating;

extern NSString * browse;
extern NSString * buddycloud; 

extern NSString * channel;
extern NSString * chooseAWildCard;
extern NSString * connecting;
extern NSString * connectingAsJID;

extern NSString * createAccount;
extern NSString * createBuddyCloudId;

extern NSString * following;
extern NSString * forgetPassword;

extern NSString * jidWithNetwork;

extern NSString * loading;
extern NSString * loginAutomatically;
extern NSString * loginMsgTitle;
extern NSString * loginServicesListTitle;

extern NSString * network1Label;
extern NSString * network2Label;
extern NSString * network3Label;

extern NSString * password;
extern NSString * passwordTip;

extern NSString * places;

extern NSString * registerAcctMsg;
extern NSString * registrationSuccess;
extern NSString * registrationSuccessDesc;

extern NSString * settings;

extern NSString * userName;
extern NSString * userNameTip;

extern NSString * welcome;
extern NSString * welcomeMsg;

//Buttons
extern NSString * cancelBtnLabel;
extern NSString * createBtnLabel;
extern NSString * createNewAcctBtnLabel;

extern NSString * exploreBtnLabel;
extern NSString * exploreChannelsBtnLabel;

extern NSString * registerBtnLabel;
extern NSString * joinBtnLabel;

extern NSString * loginBtnLabel;

extern NSString * okButtonLabel;
extern NSString * otherXmppAcctBtnLabel;


//Warnings
extern NSString * registerToAddTopic;
extern NSString * registerToFollowNewChannel;
extern NSString * registerToPostNewComment;

extern NSString * usernameIsNotValid;
extern NSString * wilcardCanNotBeEmpty;

//Error
extern NSString * alertPrompt;
extern NSString * authenticationFailed;
extern NSString * authenticatonFailedError;
extern NSString * noInternetConnError;
extern NSString * userNameConflictError;
extern NSString * userNameLoggedInConflictError;

//************************** LOCALIZABLE CONSTANTS END **************************//

@end
