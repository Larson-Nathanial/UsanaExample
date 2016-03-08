//
//  PersistentStorage.h
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersistentStorage : NSObject

@property (nonatomic) NSMutableDictionary *imagesDictionary;

+ (PersistentStorage *)storage;

- (BOOL)saveRssFeed:(NSArray *)feed;
- (BOOL)saveImages;

- (NSArray *)loadStoredRssFeed;

@end
