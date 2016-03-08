//
//  FCell.h
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSObject.h"

@interface FCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *objectImageView;
@property (weak, nonatomic) IBOutlet UILabel *objectTitle;
@property (weak, nonatomic) IBOutlet UIButton *viewButtonOutlet;
- (IBAction)viewButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *podcastAppOutlet;
@property (weak, nonatomic) IBOutlet UILabel *summary;

- (void)setupCellWithObject:(RSSObject *)object;

@property (nonatomic, copy) void (^viewButtonTapped)(id sender);
@property (nonatomic, copy) void (^failedImageSave)(id sender);

@end
