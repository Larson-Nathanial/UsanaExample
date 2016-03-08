//
//  RSSObject.h
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSObject : NSObject

@property (nonatomic, strong) NSString *rssFeed;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *appStoreUrl;
@property (nonatomic, strong) NSString *imgUrl;

- (id)initWithRssFeed:(NSString *)rssFeed title:(NSString *)title summary:(NSString *)summary appStoreUrl:(NSString *)appStoreUrl imgUrl:(NSString *)imgUrl;

+ (id)rssObjectWithRssFeed:(NSString *)rssFeed title:(NSString *)title summary:(NSString *)summary appStoreUrl:(NSString *)appStoreUrl imgUrl:(NSString *)imgUrl;

@end
