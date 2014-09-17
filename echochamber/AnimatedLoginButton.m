//
//  AnimatedLoginButton.m
//  echochamber
//
//  Created by James O'Brien on 20/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <POP.h>
#import "AnimatedLoginButton.h"
#import "FacebookConnection.h"
#import "AppDelegate.h"


static CGFloat kButtonCornerRadius = 4.0f;

static NSString *kLoginTitle = @"Log in with Facebook";


@interface AnimatedLoginButton() {
  // True when we are in the "loading" display state
  BOOL _isLoading;

  // True when we are throbbing
  BOOL _isThrobbing;

  // The shape paths the avatar transition between
  NSArray *_avatarPaths;

  // Index of the current avatar path
  int _avatarPathIdx;
  
  // Stored in case we need to return to our original size
  CGRect _origFrame;
  
  // True if There was a problem getting the user's info
  BOOL _infoErrored;
}

@property (strong, nonatomic) CAShapeLayer *avatarMaskLayer;
@property (strong, nonatomic) CAAnimation *pulseAnimation;

- (void)setup;
- (void)scaleToSmall;
- (void)scaleAnimation;
- (void)scaleToDefault;
- (void)doLogin;
- (void)doLogout;
- (void)fbNotificationRecv:(NSNotification *)notification;
- (void)updateUserImage;
@end


@implementation AnimatedLoginButton

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self setup];
  }


  return self;
}

- (id)init
{
  self = [super init];
  if (self) {
    [self setup];
  }

  return self;
}


- (void)setup
{
  self.layer.borderColor = self.tintColor.CGColor;
  self.layer.borderWidth = 1.0;
  self.layer.cornerRadius = kButtonCornerRadius;
  self.layer.masksToBounds = YES;


  [self setTitleColor:[UIColor colorWithRed:0.173 green:0.173 blue:0.153 alpha:1.000]
             forState:UIControlStateNormal];
  [self setTitle:@"Login with Facebook" forState:UIControlStateNormal];

  [self addTarget:self
           action:@selector(scaleToSmall)
 forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];

  [self addTarget:self
           action:@selector(scaleAnimation)
 forControlEvents:UIControlEventTouchUpInside];

  [self addTarget:self action:@selector(scaleToDefault) forControlEvents:UIControlEventTouchDragExit];

  [self setupPulseAnimation];
  

  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSNotificationCenter *notifications = appDelegate.facebook.notifications;
  [notifications addObserver:self selector:@selector(fbNotificationRecv:) name:nil object:nil];

  _isThrobbing = FALSE;
  _infoErrored = FALSE;
  
  _origFrame = self.frame;
}

- (void)setupPulseAnimation
{
  CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
  color.fromValue = (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
  color.toValue = (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0].CGColor;
  
  CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
  width.fromValue = @(25.0);
  width.toValue = @(0.0);
  
  CABasicAnimation *shadowRadius = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
  shadowRadius.fromValue = @(0.0);
  shadowRadius.toValue = @(13.0);
  
  
  CAAnimationGroup *all = [CAAnimationGroup animation];
  all.animations = @[color, width];
  all.duration = 2.0;
  all.repeatCount = HUGE_VALF;
  all.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

  self.pulseAnimation = all;
  
  self.pulseAnimation.delegate = self;
}


- (void)setupAvatarLayer
{
  UIBezierPath* avatarIconPath = UIBezierPath.bezierPath;
  [avatarIconPath moveToPoint: CGPointMake(50, 37)];
  [avatarIconPath addCurveToPoint: CGPointMake(47, 40) controlPoint1: CGPointMake(50, 38.65) controlPoint2: CGPointMake(48.65, 40)];
  [avatarIconPath addLineToPoint: CGPointMake(33, 40)];
  [avatarIconPath addCurveToPoint: CGPointMake(27.5, 40) controlPoint1: CGPointMake(31.35, 40) controlPoint2: CGPointMake(28.88, 40)];
  [avatarIconPath addCurveToPoint: CGPointMake(22.5, 40) controlPoint1: CGPointMake(26.12, 40) controlPoint2: CGPointMake(23.88, 40)];
  [avatarIconPath addCurveToPoint: CGPointMake(17, 40) controlPoint1: CGPointMake(21.12, 40) controlPoint2: CGPointMake(18.65, 40)];
  [avatarIconPath addLineToPoint: CGPointMake(3, 40)];
  [avatarIconPath addCurveToPoint: CGPointMake(0, 37) controlPoint1: CGPointMake(1.35, 40) controlPoint2: CGPointMake(0, 38.65)];
  [avatarIconPath addLineToPoint: CGPointMake(0, 3)];
  [avatarIconPath addCurveToPoint: CGPointMake(3, 0) controlPoint1: CGPointMake(0, 1.35) controlPoint2: CGPointMake(1.35, 0)];
  [avatarIconPath addLineToPoint: CGPointMake(47, 0)];
  [avatarIconPath addCurveToPoint: CGPointMake(50, 3) controlPoint1: CGPointMake(48.65, 0) controlPoint2: CGPointMake(50, 1.35)];
  [avatarIconPath addLineToPoint: CGPointMake(50, 37)];
  [avatarIconPath closePath];
  avatarIconPath.miterLimit = 4;
  
  
  
  UIBezierPath* speechBubblePath = UIBezierPath.bezierPath;
  [speechBubblePath moveToPoint: CGPointMake(50, 37)];
  [speechBubblePath addCurveToPoint: CGPointMake(47, 40) controlPoint1: CGPointMake(50, 38.65) controlPoint2: CGPointMake(48.65, 40)];
  [speechBubblePath addLineToPoint: CGPointMake(33, 40)];
  [speechBubblePath addCurveToPoint: CGPointMake(28.66, 42.68) controlPoint1: CGPointMake(31.35, 40) controlPoint2: CGPointMake(29.4, 41.21)];
  [speechBubblePath addLineToPoint: CGPointMake(26.34, 47.32)];
  [speechBubblePath addCurveToPoint: CGPointMake(23.66, 47.32) controlPoint1: CGPointMake(25.6, 48.79) controlPoint2: CGPointMake(24.4, 48.79)];
  [speechBubblePath addLineToPoint: CGPointMake(21.34, 42.68)];
  [speechBubblePath addCurveToPoint: CGPointMake(17, 40) controlPoint1: CGPointMake(20.6, 41.21) controlPoint2: CGPointMake(18.65, 40)];
  [speechBubblePath addLineToPoint: CGPointMake(3, 40)];
  [speechBubblePath addCurveToPoint: CGPointMake(0, 37) controlPoint1: CGPointMake(1.35, 40) controlPoint2: CGPointMake(0, 38.65)];
  [speechBubblePath addLineToPoint: CGPointMake(0, 3)];
  [speechBubblePath addCurveToPoint: CGPointMake(3, 0) controlPoint1: CGPointMake(0, 1.35) controlPoint2: CGPointMake(1.35, 0)];
  [speechBubblePath addLineToPoint: CGPointMake(47, 0)];
  [speechBubblePath addCurveToPoint: CGPointMake(50, 3) controlPoint1: CGPointMake(48.65, 0) controlPoint2: CGPointMake(50, 1.35)];
  [speechBubblePath addLineToPoint: CGPointMake(50, 37)];
  [speechBubblePath closePath];
  speechBubblePath.miterLimit = 4;
  

  _avatarPaths = @[avatarIconPath, speechBubblePath];
  _avatarPathIdx = 0;
  
  self.avatarMaskLayer = [[CAShapeLayer alloc] init];
  self.avatarMaskLayer.fillColor = [[UIColor blackColor] CGColor];
  self.avatarMaskLayer.frame = CGRectMake(self.frame.size.width/2.0 - 25.0,
                                          self.frame.size.height/2.0 - 25.0,
                                          50.0f,
                                          50.0f);
  self.avatarMaskLayer.path = ((UIBezierPath *)_avatarPaths[_avatarPathIdx]).CGPath;
  self.avatarMaskLayer.opacity = 0.0f;
}


-(void)toggleAvatarPath
{
  _avatarPathIdx = 1 - _avatarPathIdx;
  CGPathRef path = ((UIBezierPath *)_avatarPaths[_avatarPathIdx]).CGPath;
  
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
  [anim setFromValue:(id)self.avatarMaskLayer.path];
  [anim setToValue:(__bridge id)(path)];
  [anim setDelegate:self];
  [anim setDuration:0.25];
  [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  self.avatarMaskLayer.path = path;
  [self.avatarMaskLayer addAnimation:anim forKey:@"path"];
}

/*
 already logged-in    <tap>
                        |
                    [will login]
                        |
    [didLogin]          |
        |_______________|
                |
          <go to circle>
         _______|_______
        |               |
        |           [did login]
        |            (no-op)
        |               |
        |_______________|
                |
           <load info>
                |
       [did get user image]
                |
          <go to square>
              <mask>
         <set background>
          <animate mask>
         <animate to top>


*/
-(void)fbNotificationRecv:(NSNotification *)notification
{
  NSString *name = notification.name;
  NSLog(@"%@", notification.name);

  if ([name isEqualToString:kFBDidLogin]) {
    if (_isLoading == NO)
      [self transitionToLoader:NO];
  }
  else if ([name isEqualToString:kFBDidGetUserInfo]) {
    _infoErrored = NO;
  }
  else if ([name isEqualToString:kFBDidGetUserImage]) {
    if (_isThrobbing == YES)
      [self stopPulse];
    
    [self updateUserImage];
  }
  else if ([name isEqualToString:kFBErroredUserInfo]) {
    _infoErrored = YES;
    
    NSDictionary *info = notification.userInfo;
    NSString *errorMsg = [info objectForKey:kFBErrorKey];
    
    if (_isThrobbing == YES)
      [self stopPulse];
    
    if (errorMsg)
      [self setErrorMessage:errorMsg];
  }
}


- (void)doLogin
{
  [self startPulse];
  [((AppDelegate *)[UIApplication sharedApplication].delegate).facebook login];
}

- (void)doLogout
{
  [((AppDelegate *)[UIApplication sharedApplication].delegate).facebook logout];
}


- (void)updateUserImage
{
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  FacebookConnection *facebook = appDelegate.facebook;
  if (facebook.myImageUrl) {
    NSMutableURLRequest *picRequest = [NSMutableURLRequest requestWithURL:facebook.myImageUrl];
    [picRequest setTimeoutInterval:30.0f];
    [picRequest setHTTPMethod:@"GET"];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:picRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
       if (error) {
         // TODO: Error surfacing
         NSLog(@"Error getting avatar: %@", error.localizedDescription);
       } else {
         if (data.length > 0) {
           if (_isThrobbing)
             [self stopPulse];

           UIImage *avatarPic = [UIImage imageWithData:data];

           // Have to bounce this to the main thread to get it to re-display...
           [self performSelectorOnMainThread:@selector(setAvatarImageAsBackground:)
                                  withObject:avatarPic
                               waitUntilDone:NO];

           NSLog(@"Set avatar image");
         } else {
           // TODO: error surfacing
           NSLog(@"No data returned for avatar");
         }
       }
     }];
  }
}

- (void)setAvatarImageAsBackground:(UIImage *)avatar
{
  _isLoading = NO;

  if (!self.avatarMaskLayer) {
    [self setupAvatarLayer];
  }
  
  self.layer.mask = self.avatarMaskLayer;

  [self setTitle:@"" forState:UIControlStateNormal];
  self.layer.cornerRadius = 0.0;
  self.layer.contents = (__bridge id)(avatar.CGImage);

  
  POPBasicAnimation *opacityAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
  opacityAnim.fromValue = @(0.0);
  opacityAnim.toValue = @(1.0);
  opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  opacityAnim.duration = 1;
  opacityAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    [self toggleAvatarPath];
  };
  
  [self.avatarMaskLayer pop_addAnimation:opacityAnim forKey:@"maskOpacity"];
}

- (void)setErrorMessage:(NSString *)errorMessage
{
  NSLog(@"%@", errorMessage);
}

- (void)loginTapped
{
//  [self transitionToThrobber];
}

- (void) animationDidStart:(CAAnimation *)anim
{
  
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//  if ([anim isEqual:_pulseAnimation]) {
    if (_infoErrored) {
      if (_isLoading) {
        [self transitionToButton];
        _isLoading = NO;
      }
    }
//  }
}


- (void)scaleToSmall
{
  POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
  [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
}


- (void) scaleAnimation
{
  POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
  scaleAnimation.springBounciness = 18.0f;
  [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
}


- (void)scaleToDefault
{
  POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
  [self.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
}


- (void)transitionToLoader:(BOOL)doLogin
{
  if (_isLoading)
    return;

  _isLoading = YES;

  CGFloat h = _origFrame.size.height;
  CGSize newSize = CGSizeMake(h, h);

  POPBasicAnimation *toRound = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
  toRound.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  toRound.toValue = @(h/2.0);
  toRound.duration = .6;

  POPBasicAnimation *toSquare = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
  toSquare.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  toSquare.toValue = [NSValue valueWithCGSize:newSize];
  toSquare.duration = .6;

  toSquare.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    [self startPulse];
    FacebookConnection *fb = ((AppDelegate *)[UIApplication sharedApplication].delegate).facebook;
    if (doLogin == YES) {
      [fb login];
    } else {
      [fb loadMyInfo];
    }
  };


  
  [self.layer pop_addAnimation:toRound forKey:@"toRoundAnimation"];
  [self.layer pop_addAnimation:toSquare forKey:@"toSquareAnimation"];
}


- (void)transitionToButton
{
  POPBasicAnimation *toButtonSize = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
  toButtonSize.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  toButtonSize.toValue = [NSValue valueWithCGSize:_origFrame.size];
  toButtonSize.duration = 0.4;
  
  POPBasicAnimation *toButtonRadius = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
  toButtonRadius.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  toButtonRadius.toValue = @(kButtonCornerRadius);
  toButtonRadius.duration = .4;
  
  CABasicAnimation *toButtonBorderColor = [CABasicAnimation animationWithKeyPath:@"borderColor"];
  toButtonBorderColor.toValue = (id)self.tintColor.CGColor;

  CABasicAnimation *toButtonBorderWidth = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
  toButtonBorderWidth.toValue = @(1.0);
  
  CAAnimationGroup *borderTransition = [[CAAnimationGroup alloc] init];
  borderTransition.animations = @[toButtonBorderColor, toButtonBorderWidth];
  borderTransition.duration = 0.4f;
  borderTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

  toButtonSize.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    [self setTitle:kLoginTitle forState:UIControlStateNormal];
  };
  
  [self.layer pop_addAnimation:toButtonSize
                        forKey:@"toButtonSize"];
  
  [self.layer pop_addAnimation:toButtonRadius
                        forKey:@"toButtonRadius"];
  
  [self.layer addAnimation:borderTransition forKey:@"borderTransition"];
}


- (void)startPulse
{
  if (_isThrobbing)
    return;

  _isThrobbing = YES;

  [self setTitle:@"..." forState:UIControlStateNormal];


  self.layer.shadowColor = self.backgroundColor.CGColor;
  self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
  self.layer.shadowRadius = 0.0;
  self.layer.shadowOpacity = 1.0;

  [self.layer addAnimation:self.pulseAnimation forKey:@"pulse-border"];
}

- (void)stopPulse
{
  _isThrobbing = FALSE;

  [self.layer removeAnimationForKey:@"pulse-border"];
}
@end
