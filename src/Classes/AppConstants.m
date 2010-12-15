/* 
 AppConstans.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "AppConstants.h"

@implementation AppConstants

NSString * const applicationVersion = @"iPhone-0.1.01";
NSString * const appIntroVedioUrl = @"http://www.youtube.com/watch?v=WiwwRXvWN8g";

//************************** BUDDY CLOUD ENGINE SETTINGS **************************//

//**** XMPP ENGINE SETTINGS ****//
NSString * const XMPP_BC_DOMAIN = @"buddycloud.com"; 
NSString * const XMPP_BC_IPHONE_RESOURCE = @"iPhone/bcloud"; 

NSString * const XMPP_ENGINE_SERVER = @"jabber.buddycloud.com"; 
NSInteger const XMPP_ENGINE_SERVER_PORT = 5222;

NSString * const XMPP_TEMP_DEFAULT_JID = @"iphone2";
NSString * const XMPP_TEMP_DEFAULT_PASSWORD = @"iphone";

NSString * const XMPP_PUBSUB_SERVER = @"pubsub-bridge@broadcaster.buddycloud.com";

//**** PLACE ENGINE SETTINGS ****//
NSString * const PLACE_ENGINE_SERVER = @"butler.buddycloud.com";

//************************** BUDDY CLOUD ENGINE SETTINGS END **************************//



//************************** ATLAS APP URLS **************************//
NSString * kAppRootURLPath = @"tt://root/(initWithNibName:)";
NSString * kTabBarURLPath = @"tt://tabBar";
NSString * kTabBarItemURLPath = @"tt://menu/%d";
NSString * kMenuPageURLPath = @"tt://menu/(initWithMenuPage:)";

NSString * kPostURLPath = @"tt://post?_node=(initWithNode:)";
NSString * kPostWithNodeAndTitleURLPath = @"tt://post?_node=%@&title=%@";

NSString * kloginServicesWithTitleURLPath = @"tt://loginServices/(initWithTitle:)";

NSString * kloginURLPath = @"tt://networkLogin?networkId=(showNetworkLogin:)";
NSString * kloginWithNetworkIDURLPath = @"tt://networkLogin?networkId=%d";

NSString * kcreateNewAcctURLPath = @"tt://createNewAcct?title=(createNewAccount:)";

NSString * kexploreChannelsURLPath = @"tt://exploreChannels?title=(allowUserToExploreChannels:)";
NSString * kexploreChannelsWithTitleAndUsernameURLPath = @"tt://exploreChannels?title=%@&username=%@&password=%@";

//************************** ATLAS APP URLS END **************************//


//************************** UI CONSTANTS **************************//

//************************** UI CONSTANTS END **************************//


//************************** LOCALIZABLE CONSTANTS **************************//
NSString * authenticating = @"authenticating";

NSString * browse = @"browse";
NSString * buddycloud = @"buddycloud"; 

NSString * channel = @"channel";
NSString * chooseAWildCard = @"chooseAWildCard";
NSString * connecting = @"connecting";
NSString * createAccount = @"createAccount";
NSString * createBuddyCloudId = @"createBuddyCloudId";


NSString * following = @"following";
NSString * forgetPassword = @"forgetPassword";

NSString * loading = @"loading";
NSString * loginAutomatically = @"loginAutomatically";
NSString * loginMsgTitle = @"loginMsgTitle";
NSString * loginServicesListTitle = @"loginServicesListTitle";

NSString * network1Label = @"network1Label";
NSString * network2Label = @"network2Label";
NSString * network3Label = @"network3Label";

NSString * password = @"password";
NSString * passwordTip = @"passwordTip";

NSString * places = @"places";

NSString * registerAcctMsg = @"registerAcctMsg";
NSString * registrationSuccess = @"registrationSuccess";
NSString * registrationSuccessDesc = @"registrationSuccessDesc";

NSString * settings = @"settings";

NSString * userName = @"userName";
NSString * userNameTip = @"userNameTip";

NSString * welcome = @"welcome";
NSString * welcomeMsg  = @"welcomeMsg";


//Buttons
NSString * cancelBtnLabel = @"cancelBtnLabel";
NSString * createBtnLabel = @"createBtnLabel";
NSString * createNewAcctBtnLabel = @"createNewAcctBtnLabel";

NSString * exploreBtnLabel = @"exploreBtnLabel";
NSString * exploreChannelsBtnLabel = @"exploreChannelsBtnLabel";

NSString * registerBtnLabel = @"registerBtnLabel";
NSString * joinBtnLabel = @"joinBtnLabel";

NSString * loginBtnLabel = @"loginBtnLabel";

NSString * okButtonLabel = @"okButtonLabel";
NSString * otherXmppAcctBtnLabel = @"otherXmppAcctBtnLabel";


//Warnings
NSString * registerToAddTopic = @"registerToAddTopic";
NSString * registerToFollowNewChannel = @"registerToFollowNewChannel";
NSString * registerToPostNewComment = @"registerToPostNewComment";


NSString * usernameIsNotValid = @"usernameIsNotValid";
NSString * wilcardCanNotBeEmpty = @"wilcardCanNotBeEmpty";

//Error
NSString * alertPrompt = @"alertPrompt";
NSString * authenticationFailed = @"authenticationFailed";
NSString * authenticatonFailedError = @"authenticatonFailedError";
NSString * userNameConflictError = @"userNameConflictError";
NSString * userNameLoggedInConflictError = @"userNameLoggedInConflictError";


//************************** LOCALIZABLE CONSTANTS END **************************//


@end
