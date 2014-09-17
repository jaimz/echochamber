//
//  FacebookConnection.m
//  echochamber
//
//  Created by James O'Brien on 30/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FacebookConnection.h"

NSString* const kFBCheckingSession = @"fb.checking.session";

NSString* const kFBWillLogin = @"fb.will.login";
NSString* const kFBDidLogin = @"fb.did.login";
NSString* const kFBCancelledLogin = @"fb.cancelled.login";

NSString* const kFBWillLogout = @"fb.will.logout";
NSString* const kFBDidLogout = @"fb.did.logout";

NSString* const kFBWillGetUserInfo = @"fb.will.get.user.info";
NSString* const kFBDidGetUserInfo = @"fb.did.get.user.info";
NSString* const kFBErroredUserInfo = @"fb.errored.user.info";

NSString* const kFBWillGetUserImage = @"fb.will.get.user.image";
NSString* const kFBDidGetUserImage = @"fb.did.get.user.image";
NSString* const kFBErroredUserImage = @"fb.errored.userimage";

NSString* const kFBGeneralError = @"fb.general.error";
NSString* const kFBRequestError = @"fb.request.error";
NSString* const kFBRequestComplete = @"fb.request.complete";

NSString* const kFBRequestPathKey = @"fb.request.path";
NSString* const kFBErrorKey = @"fb.error";


static NSString *kMePath = @"/me";
static NSString *kMyImagePath = @"/me/picture?redirect=false&type=square&width=50";


@interface FacebookConnection ()
@property (strong, nonatomic) FBRequestConnection *requestConnection;

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;
- (void)showMessage:(NSString *)message
          withTitle:(NSString *)title;
@end


@implementation FacebookConnection

@synthesize userInfo = _userInfo;
@synthesize myImageUrl = _myImageUrl;
@synthesize requestConnection = _requestConnection;
@synthesize notifications = _notifications;

-(id)init
{
  self = [super init];
  if (self) {
    _notifications = [[NSNotificationCenter alloc] init];
  }
  
  return self;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;
{
  if (!error && state == FBSessionStateOpen) {
    [self userLoggedIn];
    return;
  }
  
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
    // Notify of logout first, then deal with any error that caused it.
    [self userLoggedOut];
  }
  
  if (error) {
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
      [self showMessage:@"Something went wrong" withTitle:[FBErrorUtility userMessageForError:error]];
    } else {
      FBErrorCategory errorCat = [FBErrorUtility errorCategoryForError:error];
      if (errorCat == FBErrorCategoryUserCancelled) {
        // User cancelled login. Just notify and bail out.
        [_notifications postNotificationName:kFBCancelledLogin object:self];
      } else if (errorCat == FBErrorCategoryAuthenticationReopenSession) {
        // A session closure has happened outside the app
        [self showMessage:@"Your current session is no longer valid. Please log in again."
                withTitle:@"Invalid session"];
      } else {
        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
        NSString *alertTitle = @"Something went wrong";
        NSString *alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists, contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
        [self showMessage:alertTitle withTitle:alertText];

        [_notifications postNotificationName:kFBGeneralError object:self userInfo:errorInformation];
      }
    }
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [self userLoggedOut];
  }
}

- (void)open
{

  if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
    // TODO(james): Can the completion handler here be made a property of this class?
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:NO
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                    [self sessionStateChanged:session state:state error:error];
                                  }];
  }
}

- (void)close
{
  FBSession *active = FBSession.activeSession;
  if (active.state == FBSessionStateOpen ||
      active.state == FBSessionStateOpenTokenExtended)
  {
    [active closeAndClearTokenInformation];
  }
}

-(void)login
{
  [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                     allowLoginUI:YES
                                completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                  [self sessionStateChanged:session state:state error:error];
                                }];
}

- (void)logout
{
  [FBSession.activeSession closeAndClearTokenInformation];
}


- (void)loadMyInfo
{
  [_notifications postNotificationName:kFBWillGetUserInfo object:self];
  
  NSArray *paths = @[kMePath, kMyImagePath];
  
  FBRequestConnection *connection = [[FBRequestConnection alloc] init];
  
  for (NSString *path in paths) {
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
      [self requestCompleted:connection forPath:path result:result error:error];
    };
    
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:path];
    [connection addRequest:request completionHandler:handler];
  }
  
  [connection start];
}

- (void) requestCompleted:(FBRequestConnection *)connection
                  forPath:(NSString *)path
                   result:(id)result
                    error:(NSError *)error
{
  NSString *notificationName = nil;
 
  // Our connection?
  if (self.requestConnection && connection != self.requestConnection) {
    // No. Bail out.
    return;
  }
  
  // Sanity
  self.requestConnection = nil;
  
  if (error) {
    NSDictionary *errorInfo = @{kFBErrorKey: error.localizedDescription,
                                kFBRequestPathKey: path};
    
    notificationName = kFBRequestError;
    if ([path isEqualToString:kMePath]) {
      notificationName = kFBErroredUserInfo;
    }
    else if ([path isEqualToString:kMyImagePath]) {
      notificationName = kFBErroredUserImage;
    }
    
    [_notifications postNotificationName:notificationName
                                  object:self
                                userInfo:errorInfo];
    return;
  }
  

  if ([path isEqualToString:kMePath]) {
    // Yuck
    _userInfo = (id<FBGraphUser>)[FBGraphObject graphObjectWrappingDictionary:((NSDictionary *) result)];
    notificationName = kFBDidGetUserInfo;
  }
  else if ([path isEqualToString:kMyImagePath]) {
    NSDictionary *myImageResult = (NSDictionary *)result;
    _myImageUrl = [NSURL URLWithString:[[myImageResult valueForKey:@"data"] valueForKey:@"url"]];
    notificationName = kFBDidGetUserImage;
  }
  
  if (notificationName)
    [_notifications postNotificationName:notificationName object:self userInfo:result];
}

- (void)userLoggedIn
{
  [_notifications postNotificationName:kFBDidLogin
                                object:self
                              userInfo:nil];
//  [self loadMyInfo];
}

- (void)userLoggedOut
{
  [_notifications postNotificationName:kFBDidLogout
                                                      object:self
                                                    userInfo:nil];
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:text
                             delegate:nil
                    cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
