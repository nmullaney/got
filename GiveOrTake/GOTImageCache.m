//
//  GOTImageCache.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 9/9/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTImageCache.h"
#import "GOTImageCacheObject.h"

@implementation GOTImageCache

- (id)init
{
    self = [super init];
    if (self != nil) {
        cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setImage:(UIImage *)image forKey:(id <NSCopying>)key {
    GOTImageCacheObject *cacheObject = [[GOTImageCacheObject alloc] initWithImage:image];
    [cache setObject:cacheObject forKey:key];
}

- (UIImage *)imageForKey:(id <NSCopying>)key {
    GOTImageCacheObject *cacheObject = [cache objectForKey:key];
    if (cacheObject == nil) {
        return nil;
    }
    return [cacheObject image];
}

- (UIImage *)imageForKey:(id <NSCopying>)key after:(NSDate *)date {
    GOTImageCacheObject *cacheObject = [cache objectForKey:key];
    if (cacheObject == nil) {
        return nil;
    }
    NSDate *updateDate = [cacheObject updateDate];
    if ([updateDate compare:date] != NSOrderedDescending) {
        return nil;
    }
    return [cacheObject image];
}

- (void)removeImageForKey:(id)key {
    [cache removeObjectForKey:key];
}

- (void)removeAllImages {
    [cache removeAllObjects];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    [cache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        GOTImageCacheObject *cacheObject = (GOTImageCacheObject *) obj;
        UIImage *image = [cacheObject image];
        block(key, image, stop);
    }];
}

@end
