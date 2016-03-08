//
//  PersistentStorage.m
//  UsanaExample
//
//  Created by Nathan Larson on 3/7/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "PersistentStorage.h"
#import "RSSObject.h"
#import <objc/runtime.h>

@implementation PersistentStorage

+ (PersistentStorage *)storage
{
    static PersistentStorage *storage = nil;
    
    if (!storage) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            storage = [[self alloc] initPrivate];
        });
    }
    return storage;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"images"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (dictionary == nil) {
        self.imagesDictionary = [NSMutableDictionary new];
    }else {
        NSMutableDictionary *mDictionary = [NSMutableDictionary new];
        for (NSString *key in dictionary) {
            UIImage *image = [UIImage imageWithData:[dictionary objectForKey:key] scale:1.0];
            [mDictionary setObject:image forKey:key];
        }
        self.imagesDictionary = [NSMutableDictionary dictionaryWithDictionary:mDictionary];
    }
    
    return self;
}

- (BOOL)saveImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"images"];
    
    NSMutableDictionary *mDictionary = [NSMutableDictionary new];
    for (NSString *key in self.imagesDictionary) {
        NSData *d = UIImageJPEGRepresentation((UIImage *)[self.imagesDictionary objectForKey:key], 1.0);
        [mDictionary setObject:d forKey:key];
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:mDictionary];
    
    BOOL complete = [dictionary writeToFile:filePath atomically:YES];
    if (complete) {
        complete = [self addSkipBackupAttributeToItemAtPath:filePath];
    }
    return complete;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (BOOL)saveRssFeed:(NSArray *)feed
{
    NSMutableArray *array = [NSMutableArray new];
    
    @autoreleasepool {
        unsigned int numProperties = 0;
        objc_property_t *properties = class_copyPropertyList([RSSObject class], &numProperties);
        for (RSSObject *object in feed) {
            NSMutableDictionary *mDictionary = [NSMutableDictionary new];
            for (NSUInteger i = 0; i < numProperties; i++)
            {
                objc_property_t property = properties[i];
                NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
                [mDictionary setValue:[object valueForKey:name] forKey:name];
            }
            NSDictionary *d = [NSDictionary dictionaryWithDictionary:mDictionary];
            [array addObject:d];
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"rss_feed"];
    
    NSArray *yArray = [NSArray arrayWithArray:array];
    
    BOOL complete = [yArray writeToFile:filePath atomically:YES];
    
    return complete;
}

- (NSArray *)loadStoredRssFeed
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"rss_feed"];
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSMutableArray *rArray = [NSMutableArray new];
    
    for (NSDictionary *d in array) {
        NSArray *uArray = [d allKeys];
        RSSObject *object = [RSSObject rssObjectWithRssFeed:nil title:nil summary:nil appStoreUrl:nil imgUrl:nil];
        for (NSString *key in uArray) {
            [object setValue:[d valueForKey:key] forKey:key];
        }
        [rArray addObject:object];
    }
    
    return rArray;
}


@end
