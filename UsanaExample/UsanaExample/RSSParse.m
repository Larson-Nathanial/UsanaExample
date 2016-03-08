//
//  RSSParse.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "RSSParse.h"
#import "RSSObject.h"

@interface RSSParse ()<NSXMLParserDelegate>

@property (nonatomic) NSArray *urls;
@property (nonatomic) NSXMLParser *parser;
@property (nonatomic) NSMutableArray *completedArray;

@property (nonatomic) NSString *currentElement;
@property (nonatomic) BOOL withinRSS;
@property (nonatomic) int countOfDocuments;

@property (nonatomic) NSString *articleTitle;
@property (nonatomic) NSString *articleSummary;
@property (nonatomic) NSString *appStoreUrl;
@property (nonatomic) NSString *imgUrl;

@end

@implementation RSSParse

+ (RSSParse *)parse
{
    static RSSParse *parse = nil;
    
    if (!parse) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            parse = [[self alloc] initPrivate];
        });
    }
    return parse;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    self.urls = @[@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topfreeapplications/limit=25/xml"
                  , @"http://itunes.apple.com/us/rss/toppodcasts/limit=25/xml"];
    
    return self;
}

- (NSArray *)loadRssFeedsForStoredUrls
{
    self.withinRSS = NO;
    self.countOfDocuments = 0;
    self.completedArray = [NSMutableArray new];
    
    for (NSString *urlString in self.urls) {
        NSURL *url = [NSURL URLWithString:urlString];
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        [self.parser setDelegate:self];
        [self.parser setShouldResolveExternalEntities:NO];
        [self.parser parse];
    }
    
    return self.completedArray;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.currentElement = elementName;

    if (self.withinRSS) {
        if ([elementName isEqualToString:@"entry"]) {
            self.articleTitle = [NSString new];
            self.articleSummary = [NSString new];
            self.appStoreUrl = [NSString new];
            self.imgUrl = [NSString new];
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (self.withinRSS) {
        if ([self.currentElement isEqualToString:@"title"]) {
            self.articleTitle = [self.articleTitle stringByAppendingString:string];
        }else if ([self.currentElement isEqualToString:@"summary"]) {
            self.articleSummary = [self.articleSummary stringByAppendingString:string];
        }else if ([self.currentElement isEqualToString:@"id"] && self.appStoreUrl.length == 0) {
            self.appStoreUrl = string;
        }else if ([self.currentElement isEqualToString:@"im:image"] && self.imgUrl.length == 0) {
            self.imgUrl = string;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    
    if (!self.withinRSS) {
        if ([elementName isEqualToString:@"title"]) {
            self.withinRSS = YES;
        }
    }
    
    
    if (self.withinRSS) {
        if ([elementName isEqualToString:@"entry"]) {
            if (self.countOfDocuments == 0) {
                [self.completedArray addObject:[RSSObject rssObjectWithRssFeed:@"App" title:self.articleTitle summary:self.articleSummary appStoreUrl:self.appStoreUrl imgUrl:self.imgUrl]];
            }else {
                [self.completedArray addObject:[RSSObject rssObjectWithRssFeed:@"Podcast" title:self.articleTitle summary:self.articleSummary appStoreUrl:self.appStoreUrl imgUrl:self.imgUrl]];
            }
            
        }
        
        
        if ([elementName isEqualToString:@"rss"]) {
            self.withinRSS = NO;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    self.countOfDocuments++;
    
}



@end
