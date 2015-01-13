//
//  AppDelegate.m
//  echochamber
//
//  Created by James O'Brien on 18/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "StoryViewController.h"
#import "FacebookConnection.h"

@implementation AppDelegate

// During the Facebook login flow, your app passes control to the Facebook iOS app or
// Facebook in a mbile  browser. After authentication, the app will be called back with
// the session information
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // This ensures the FBLoginView is loaded before any views are shown
  //[FBLoginView class];
  self.facebook = [[FacebookConnection alloc] init];
  
  self.window.rootViewController = [[MainViewController alloc] init];
//  self.window.rootViewController = [[StoryViewController alloc] init];
 
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  // comment this out here for demo purposes
  //[self.facebook open];
  
  return YES;
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                             message:text
                            delegate:nil
                    cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in
  // the background, optionally refresh the user interface.
  
  // Handle the user leaving the app while the Facebook login dialog is being shown
  // For example: whne the user presses the iOS "home" button while the login dialog is active
  [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
