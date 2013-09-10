//
//  GOTImageCache.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 9/9/13.
//
// This is a update-time aware image cache object. It wraps an NSMutableDictionary.
//
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTImageCache : NSObject {
        NSMutableDictionary *cache;
}

- (void)setImage:(UIImage *)image forKey:(id <NSCopying>)key;
- (UIImage *)imageForKey:(id <NSCopying>)key;
- (UIImage *)imageForKey:(id <NSCopying>)key after:(NSDate *)date;
- (void)removeImageForKey:(id)key;
- (void)removeAllImages;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;


@end
