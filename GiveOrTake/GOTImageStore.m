//
//  GOTImageStore.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTImageStore.h"

@implementation GOTImageStore

+ (GOTImageStore *)sharedStore
{
    static GOTImageStore *imageStore = nil;
    if (!imageStore) {
        imageStore = [[GOTImageStore alloc] init];
    }
    return imageStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        imageCache = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [imageCache setObject:i forKey:s];
}

- (UIImage *)imageForKey:(NSString *)s
{
    return [imageCache objectForKey:s];
}

- (void)deleteImageForKey:(NSString *)s
{
    if (!s) {
        return;
    }
    [imageCache removeObjectForKey:s];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Clearing %d images", [imageCache count]);
    [imageCache removeAllObjects];
}

@end
