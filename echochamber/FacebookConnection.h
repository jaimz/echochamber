//
//  FacebookConnection.h
//  echochamber
//
//  Created by James O'Brien on 30/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString* const kFBCheckingSession;

extern NSString* const kFBWillLogin;
extern NSString* const kFBDidLogin;

extern NSString* const kFBWillLogout;
extern NSString* const kFBDidLogout;

extern NSString* const kFBWillGetUserInfo;
extern NSString* const kFBDidGetUserInfo;
extern NSString* const kFBErroredUserInfo;

extern NSString* const kFBWillGetUserImage;
extern NSString* const kFBDidGetUserImage;
extern NSString* const kFBErroredUserImage;

extern NSString* const kFBGeneralError;
extern NSString* const kFBRequestError;
extern NSString* const kFBRequestComplete;

extern NSString* const kFBErrorKey;
extern NSString* const kFBRequestPathKey;


@interface FacebookConnection : NSObject
@property (strong, nonatomic, readonly) id<FBGraphUser> userInfo;
@property (strong, nonatomic, readonly) NSURL *myImageUrl;
@property (strong, nonatomic, readonly) NSNotificationCenter *notifications;

-(void)open;
-(void)login;
-(void)loadMyInfo;
-(void)logout;

@end
