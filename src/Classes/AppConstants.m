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
NSString * const XMPP_ENGINE_SERVER = @"jabber.buddycloud.com"; 
NSInteger const XMPP_ENGINE_SERVER_PORT = 5222;

NSString * const XMPP_TEMP_DEFAULT_JID = @"iphone2@buddycloud.com/iPhone/bcloud";
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

//************************** ATLAS APP URLS END **************************//


//************************** UI CONSTANTS **************************//

//************************** UI CONSTANTS END **************************//


//************************** LOCALIZABLE CONSTANTS **************************//
NSString * browse = @"browse";
NSString * buddycloud = @"buddycloud"; 

NSString * channel = @"channel";

NSString * following = @"following";

NSString * places = @"places";

NSString * settings = @"settings";

NSString * welcome = @"welcome";
NSString * welcomeMsg  = @"welcomeMsg";




//Buttons
NSString * exploreBtnLabel = @"exploreBtnLabel";
NSString * joinBtnLabel = @"joinBtnLabel";



//************************** LOCALIZABLE CONSTANTS END **************************//


@end
