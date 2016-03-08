//
//  WelcomeView.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "WelcomeView.h"
#import "FeedViewController.h"

@implementation WelcomeView

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:90.0 / 255.0 green:203.0 /255.0  blue:255.0 / 255.0 alpha:1.0];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(0.0, 50.0, self.view.bounds.size.width, 80.0);
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:35.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"USANA Example";
    [self.view addSubview:titleLabel];
    
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake((self.view.bounds.size.width / 2.0) - 50.0, 180.0, 100.0, 100.0);
    imageView.image = [UIImage imageNamed:@"rss_image"];
    [self.view addSubview:imageView];
    
    UILabel *descriptLabel = [UILabel new];
    descriptLabel.frame = CGRectMake(40.0, 300.0, self.view.bounds.size.width - 80.0, 200.0);
    descriptLabel.textAlignment = NSTextAlignmentCenter;
    descriptLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25.0];
    descriptLabel.numberOfLines = 0;
    descriptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptLabel.textColor = [UIColor whiteColor];
    descriptLabel.text = @"See the top 25 free iOS apps and the top 25 podcasts";
    [self.view addSubview:descriptLabel];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    goButton.frame = CGRectMake(40.0, self.view.bounds.size.height - 150.0, self.view.bounds.size.width - 80.0, 50.0);
    goButton.backgroundColor = [UIColor whiteColor];
    goButton.layer.cornerRadius = 25.0;
    [goButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:13.0]];
    [goButton setTintColor:[UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [goButton setTitle:[@"Check it out" uppercaseString] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(goButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];
}

- (void)goButtonTapped
{
    FeedViewController *viewController = [FeedViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
