/* 
 DirectoryItem.h
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/22/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import <Foundation/Foundation.h>

@interface DirectoryItem : NSObject {
	NSString *directoryId;
	NSString *title;
	
	NSString *description;
}

@property (nonatomic, retain) NSString *directoryId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;

@end
