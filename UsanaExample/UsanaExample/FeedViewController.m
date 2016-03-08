//
//  FeedViewController.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "FeedViewController.h"
#import "RSSParse.h"
#import "PersistentStorage.h"
#import "RSSObject.h"
#import "FCell.h"

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIView *coverView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *feedObjects;
@property (nonatomic) NSDateFormatter *dFormatter;
@property (nonatomic) BOOL didRefresh;

@end

@implementation FeedViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:90.0 / 255.0 green:203.0 /255.0  blue:255.0 / 255.0 alpha:1.0];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationItem setHidesBackButton:YES];
    
    // Custom Navigation bar look...
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [[UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:56.0 / 255.0 alpha:0.2] setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadRSSFeed)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    self.dFormatter = [NSDateFormatter new];
    [self.dFormatter setDateFormat:@"MMMM dd, yyyy h:m aaa"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width - 0.0, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FCell class])];
    [self.view addSubview:self.tableView];
    
    self.didRefresh = NO;
    
    _coverView = [UIView new];
    _coverView.frame = self.view.frame;
    _coverView.backgroundColor = [UIColor colorWithWhite:34.0 / 255.0 alpha:0.8];
    [self.view addSubview:_coverView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = self.view.center;
    [_activityIndicator startAnimating];
    [_coverView addSubview:_activityIndicator];
    _coverView.alpha = 0.0;
    
    [self getRSSFeed];
}

- (void)reloadRSSFeed
{
    self.didRefresh = YES;
    [self getRSSFeed];
}

- (void)getRSSFeed
{
    [UIView animateWithDuration:0.6 animations:^{
        _coverView.alpha = 1.0;
    }];
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        
        if (self.didRefresh) {
            self.feedObjects = [[RSSParse parse] loadRssFeedsForStoredUrls];
            
            [[NSUserDefaults standardUserDefaults] setValue:[self.dFormatter stringFromDate:[NSDate date]] forKey:@"last_update"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setLastUpdateDateTime];
                
                if (self.feedObjects.count == 0) {
                    [self displayErrorWithTitle:@"Error" andMessage:@"Please ensure you have an internet connection and try again."];
                }else {
                    BOOL success = [[PersistentStorage storage] saveRssFeed:self.feedObjects];
                    if (!success) {
                        [self displayErrorWithTitle:@"Failed to save Feed" andMessage:@"RSS Fees will be re-downloaded each time."];
                    }
                    [self.tableView reloadData];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    _coverView.alpha = 0.0;
                }];
            });
        }else {
            self.feedObjects = [[PersistentStorage storage] loadStoredRssFeed];
            if (self.feedObjects.count == 0) {
                
                self.feedObjects = [[RSSParse parse] loadRssFeedsForStoredUrls];
                
                [[NSUserDefaults standardUserDefaults] setValue:[self.dFormatter stringFromDate:[NSDate date]] forKey:@"last_update"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self setLastUpdateDateTime];
                    
                    if (self.feedObjects.count == 0) {
                        [self displayErrorWithTitle:@"Error" andMessage:@"Please ensure you have an internet connection and try again."];
                    }else {
                        BOOL success = [[PersistentStorage storage] saveRssFeed:self.feedObjects];
                        if (!success) {
                            [self displayErrorWithTitle:@"Failed to save Feed" andMessage:@"RSS Fees will be re-downloaded each time."];
                        }
                        [self.tableView reloadData];
                    }
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        _coverView.alpha = 0.0;
                    }];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setLastUpdateDateTime];
                    [self.tableView reloadData];
                    [UIView animateWithDuration:0.3 animations:^{
                        _coverView.alpha = 0.0;
                    }];
                });
                
            }
        }
    });
}

- (void)setLastUpdateDateTime
{
    self.navigationItem.titleView = nil;
    
    UIView *titleView = [UIView new];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.frame = CGRectMake(0.0, 0.0, 200.0, 44.0);
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(0.0, 0.0, 200.0, 32.0);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0];
    titleLabel.text = @"USANA Example";
    [titleView addSubview:titleLabel];
    
    UILabel *lastUpdatedLabel = [UILabel new];
    lastUpdatedLabel.frame = CGRectMake(0.0, 30.0, 200.0, 10.0);
    lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
    lastUpdatedLabel.textColor = [UIColor whiteColor];
    lastUpdatedLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:10.0];
    
    lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"last_update"]];
    
    
    [titleView addSubview:lastUpdatedLabel];
    
    self.navigationItem.titleView = titleView;
    
    self.didRefresh = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [((RSSObject *)[self.feedObjects objectAtIndex:indexPath.row]).summary boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 32.0, MAXFLOAT)
                                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                     attributes:@{
                                                                                                                  NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:15.0]
                                                                                                                  }
                                                                                                        context:nil].size;
    
    
    return 360.0 - 29.0 + size.height + 7.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FCell class]) forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setupCellWithObject:(RSSObject *)[self.feedObjects objectAtIndex:indexPath.row]];
    
    cell.viewButtonTapped = ^(id sender){
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:((RSSObject *)[self.feedObjects objectAtIndex:indexPath.row]).appStoreUrl]];
        
    };
    
    cell.failedImageSave = ^(id sender){
        [self displayErrorWithTitle:@"Failed to save Image" andMessage:@"You might want to be on wifi if you aren't already to save on data usage :)"];
    };
    
    return cell;
}

- (void)displayErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
