//
//  StoryViewController.m
//  echochamber
//
//  Created by James O'Brien on 10/09/2014.
//  Copyright (c) 2014 James O'Brien. All rights reserved.
//

#import "StoryViewController.h"

@interface StoryViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation StoryViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
