//
//  MainViewController.m
//  echochamber
//
//  Created by James O'Brien on 19/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <POP.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "AnimatedLoginButton.h"


@interface MainViewController () {
  BOOL _errorVisible;
}

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet AnimatedLoginButton *loginView;
@property (strong, nonatomic) IBOutlet UILabel *errorBanner;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIView *toolbarBacking;

- (IBAction)logoutButtonTapped:(id)sender;
- (IBAction)loginButtonTouched:(id)sender;

- (void)fbNotificationRecv:(NSNotification *)notification;
- (void)showError:(NSString *)msg;
- (void)hideError;
- (void)moveLoginButtonToTop;
@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view.layer setContents:(__bridge id)([UIImage imageNamed:@"liverpool_fog_vblur.jpg"]).CGImage];
  _errorVisible = NO;
  CGPoint topCenter = CGPointMake(0.5, 0);
  self.errorBanner.layer.anchorPoint = topCenter;
  
  CGRect ourFrame = self.view.frame;
  
  self.toolbarBacking = [[UIView alloc] init];
  [self.toolbarBacking.layer setFrame:CGRectMake(0.0, 0.0, 320, 0.0)];
  self.toolbarBacking.layer.backgroundColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] CGColor];
  self.toolbarBacking.layer.anchorPoint = topCenter;
  self.toolbarBacking.layer.shadowColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.153 alpha:0.70].CGColor;
  self.toolbarBacking.layer.shadowOffset = CGSizeMake(0, 1);
  self.toolbarBacking.layer.shadowOpacity = 1;
  self.toolbarBacking.layer.shadowRadius = 0;
  
  /*
  self.loginView = [[AnimatedLoginButton alloc] init];
  [self.loginView.layer setFrame:CGRectMake(16, (ourFrame.size.height / 2) - 25, ourFrame.size.width - 32, 50)];
  [self.loginView addTarget:self
                     action:@selector(loginButtonTouched:)
           forControlEvents:UIControlEventTouchUpInside];
  */
  
  [self.view addSubview:self.toolbarBacking];
  [self.view addSubview:self.loginView];
  
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSNotificationCenter *notifications = appDelegate.facebook.notifications;
  [notifications addObserver:self selector:@selector(fbNotificationRecv:) name:nil object:nil];
}

- (void)fbNotificationRecv:(NSNotification *)notification
{
  NSString *name = notification.name;
  if ([name isEqualToString:kFBDidGetUserInfo]) {
    if (_errorVisible)
      [self hideError];
    
//    [self moveLoginButtonToTop];
  }
  else if ([name isEqualToString:kFBDidGetUserImage]) {
    [self moveLoginButtonToTop];
  }
  else if ([name isEqualToString:kFBErroredUserInfo]) {
    [self showError:@"Could not get user info"];
  }
  else if ([name isEqualToString:kFBGeneralError]) {
    NSString *msg = nil;
    NSDictionary *info = notification.userInfo;
    if (info) {
      msg = [info objectForKey:kFBErrorKey];
    }
    
    if (!msg)
      msg = @"Error contacting Facebook";
    
    [self showError:msg];
  }
}

- (void)showError:(NSString *)msg
{
  if (msg) {
    if (_errorVisible) {
      [self.errorBanner setText:msg];
    } else {
      CGRect currBounds = self.errorBanner.bounds;
      CGRect targetBounds = CGRectMake(currBounds.origin.x, currBounds.origin.y, currBounds.size.width, 40);
      POPSpringAnimation *reveal = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
      reveal.toValue = [NSValue valueWithCGRect:targetBounds];
      
      reveal.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [self.errorBanner setText:msg];
      };
      
      [self.errorBanner pop_addAnimation:reveal forKey:@"reveal"];
    }
  } else {
    [self hideError];
  }
}

- (void)hideError
{
  if (_errorVisible) {
    CGRect currBounds = self.errorBanner.bounds;
    CGRect targetBounds = CGRectMake(currBounds.origin.x, currBounds.origin.y, currBounds.size.width, 0);
    POPSpringAnimation *hide = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    hide.toValue = [NSValue valueWithCGRect:targetBounds];
    
    [self.errorBanner pop_addAnimation:hide forKey:@"hide"];
  }
}

- (void)moveLoginButtonToTop
{
  CGPoint currPosn = self.loginView.layer.position;
  CGPoint targetPosn = CGPointMake(currPosn.x, 52.0);
  
  POPSpringAnimation *posnAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
  posnAnim.toValue = [NSValue valueWithCGPoint:targetPosn];
  posnAnim.springBounciness = 4;
  
  posnAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    [self.loginView toggleBubblePath];
  };

  
  CGRect tbBounds = self.toolbarBacking.layer.bounds;
  CGRect tbTargetBounds = CGRectMake(tbBounds.origin.x, tbBounds.origin.y, tbBounds.size.width, 64.0 /*36.0*/);
  
  POPSpringAnimation *tbAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
  tbAnim.toValue = [NSValue valueWithCGRect:tbTargetBounds];
  tbAnim.springBounciness = 4;
  
  [self.loginView pop_addAnimation:posnAnim forKey:@"posnAnim"];
  [self.toolbarBacking pop_addAnimation:tbAnim forKey:@"appear"];
}

- (IBAction)logoutButtonTapped:(id)sender {
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate.facebook logout];
  
//  [self moveLoginButtonToTop];
}

- (IBAction)loginButtonTouched:(id)sender
{
//  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  //[appDelegate.facebook login];
  
  // Used for demo purposes - we know that we are already logged into facebook
  // and we still want to capture the initial state of the button.
//  [appDelegate.facebook open];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
  self.profilePictureView.profileID = user.objectID;
  self.nameLabel.text = user.name;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
  self.statusLabel.text = @"Your're logged as";
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
  self.statusLabel.text = @"You are not logged in!";
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
  NSString *alertTitle, *alertMessage;
  
  // If the user should perform an action outside the app the SDK will provide a message,
  // we just need to surface it...
  if ([FBErrorUtility shouldNotifyUserForError:error]) {
    alertTitle = @"Facebook error";
    alertMessage = [FBErrorUtility userMessageForError:error];
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
    // Handle session closures that happen outside the app.
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid";
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
    // User has cancelled the login process
    NSLog(@"user cancelled login");
  } else {
    alertTitle = @"Something went wrong";
    alertMessage = @"Please try again later";
    NSLog(@"Unexpected error: %@", error);
  }
  
  if (alertMessage) {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}
@end
