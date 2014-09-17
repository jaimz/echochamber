//
//  LoginViewController.m
//  echochamber
//
//  Created by James O'Brien on 18/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"

@interface LoginViewController () <FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
  FBLoginView *loginView = [[FBLoginView alloc] init];
  loginView.delegate = self;
  
  // Horizontally center
  loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 5);
  [self.view addSubview:loginView];
  
  self.profilePictureView = [[FBProfilePictureView alloc] init];
  self.profilePictureView.frame = CGRectOffset(self.profilePictureView.frame, 0, loginView.frame.origin.y + loginView.frame.size.height + 20);
  [self.view addSubview:self.profilePictureView];
  
  self.nameLabel = [[UILabel alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLogin

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
  self.profilePictureView.profileID = user.objectID;
  self.nameLabel.text = user.name;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
  self.statusLabel.text = @"You're logged in as";
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
  self.profilePictureView.profileID = nil;
  self.nameLabel.text = @"";
  self.statusLabel.text = @"You are not logged in!";
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
