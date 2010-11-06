/* 
 AppConstans.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 10/26/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */


#import <Foundation/Foundation.h>


@interface AppConstants

extern NSString * const applicationVersion;
extern NSString * const appIntroVedioUrl;

//************************** BUDDY CLOUD ENGINE SETTINGS **************************//

//**** XMPP ENGINE SETTINGS ****//
extern NSString	* const XMPP_ENGINE_SERVER;
extern NSInteger const XMPP_ENGINE_SERVER_PORT;

extern NSString * const XMPP_TEMP_DEFAULT_JID;
extern NSString * const XMPP_TEMP_DEFAULT_PASSWORD;

extern NSString * const XMPP_PUBSUB_SERVER;

//**** PLACE ENGINE SETTINGS ****//
extern NSString * const PLACE_ENGINE_SERVER;

//************************** BUDDY CLOUD ENGINE SETTINGS END **************************//



//************************** ATLAS APP URLS **************************//
extern NSString * kAppRootURLPath;
extern NSString * kTabBarURLPath;
extern NSString * kTabBarItemURLPath;
extern NSString * kMenuPageURLPath;

extern NSString * kPostURLPath;
extern NSString * kPostWithNodeAndTitleURLPath;

//************************** ATLAS APP URLS END **************************//


//************************** UI CONSTANTS **************************//

//************************** UI CONSTANTS END **************************//


//************************** LOCALIZABLE CONSTANTS **************************//

extern NSString * browse;
extern NSString * buddycloud; 

extern NSString * channel;

extern NSString * following;

extern NSString * places;

extern NSString * settings;

extern NSString * welcome;
extern NSString * welcomeMsg;




//Buttons
extern NSString * exploreBtnLabel;
extern NSString * joinBtnLabel;


//************************** LOCALIZABLE CONSTANTS END **************************//

@end
