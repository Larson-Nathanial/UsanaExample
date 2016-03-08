//
//  RSSParse.h
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSParse : NSObject

+ (RSSParse *)parse;

- (NSArray *)loadRssFeedsForStoredUrls;

@end
