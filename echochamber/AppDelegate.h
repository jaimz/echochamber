//
//  AppDelegate.h
//  echochamber
//
//  Created by James O'Brien on 18/08/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookConnection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FacebookConnection *facebook;

@end
