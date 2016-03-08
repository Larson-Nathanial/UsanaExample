//
//  FCell.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "FCell.h"
#import "PersistentStorage.h"

@implementation FCell

- (IBAction)viewButtonAction:(id)sender {
    self.viewButtonTapped(sender);
}

- (void)setupCellWithObject:(RSSObject *)object
{
    self.podcastAppOutlet.text = object.rssFeed;
    
    if ([object.rssFeed isEqualToString:@"App"]) {
        [self.viewButtonOutlet setTitle:@"View on App Store" forState:UIControlStateNormal];
    }else {
        [self.viewButtonOutlet setTitle:@"View on iTunes" forState:UIControlStateNormal];
    }
    
    self.podcastAppOutlet.layer.cornerRadius = 10.0;
    self.podcastAppOutlet.layer.masksToBounds = YES;
    
    self.viewButtonOutlet.layer.cornerRadius = 25.0;
    self.viewButtonOutlet.layer.masksToBounds = YES;
    
    self.objectImageView.layer.cornerRadius = 15.0;
    self.objectImageView.layer.masksToBounds = YES;
    
    self.objectTitle.text = object.title;
    
    self.summary.text = object.summary;
    
    [[self.objectImageView viewWithTag:638] removeFromSuperview];
    UIView *coverView = [UIView new];
    coverView.tag = 638;
    coverView.frame = CGRectMake(0.0, 0.0, self.objectImageView.frame.size.width, self.objectImageView.frame.size.height);
    coverView.backgroundColor = [UIColor colorWithWhite:34.0 / 255.0 alpha:0.8];
    [self.objectImageView addSubview:coverView];
    
    [[self.objectImageView viewWithTag:628] removeFromSuperview];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.tag = 628;
    activityIndicator.center = coverView.center;
    [activityIndicator startAnimating];
    [coverView addSubview:activityIndicator];
    coverView.alpha = 1.0;
    
    if ([[[PersistentStorage storage] imagesDictionary] objectForKey:object.imgUrl]) {
        
        self.objectImageView.image = [[[PersistentStorage storage] imagesDictionary] objectForKey:object.imgUrl];
        [UIView animateWithDuration:0.3 animations:^{
            coverView.alpha = 0.0;
        }];
        
    }else {
        
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^{
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", object.imgUrl]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.objectImageView.image = [[UIImage alloc] initWithData:data];
                    [[[PersistentStorage storage] imagesDictionary] setObject:[[UIImage alloc] initWithData:data] forKey:object.imgUrl];
                    [activityIndicator stopAnimating];
                    
                    BOOL success = [[PersistentStorage storage] saveImages];

                    if (!success) {
                        self.failedImageSave(@"failed");
                    }
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        coverView.alpha = 0.0;
                    }];
                });
            }
        });
    }
}

@end
