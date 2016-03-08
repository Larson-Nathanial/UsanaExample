//
//  RSSObject.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "RSSObject.h"

@implementation RSSObject

- (id)initWithRssFeed:(NSString *)rssFeed title:(NSString *)title summary:(NSString *)summary appStoreUrl:(NSString *)appStoreUrl imgUrl:(NSString *)imgUrl
{
    self = [super init];
    if (self) {
        self.rssFeed = rssFeed;
        self.title = title;
        self.summary = summary;
        self.appStoreUrl = appStoreUrl;
        self.imgUrl = imgUrl;
    }
    return self;
}

+ (id)rssObjectWithRssFeed:(NSString *)rssFeed title:(NSString *)title summary:(NSString *)summary appStoreUrl:(NSString *)appStoreUrl imgUrl:(NSString *)imgUrl
{
    return [[self alloc] initWithRssFeed:rssFeed title:title summary:summary appStoreUrl:appStoreUrl imgUrl:imgUrl];
}

@end
