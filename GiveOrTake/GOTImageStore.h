//
//  GOTImageStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItem;

@interface GOTImageStore : NSObject
{
    NSMutableDictionary *imageCache;
}

+ (GOTImageStore *)sharedStore;
+ (NSString *)createImageKey;
+ (NSString *)imageCachePath;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s updatedAfter:(NSDate *)date;
- (void)deleteImageForKey:(NSString *)s;
- (void)clearCache:(NSNotification *)note;
- (void)saveCacheToDisk;
- (void)deleteOldImagesOnDisk;
- (NSString *)filePathForKey:(NSString *)key;

- (void)uploadImageForKey:(NSString *)s withItemID:(NSNumber *)itemID;
- (void)fetchImageForItem:(GOTItem *)item withCompletion:(void (^)(id image, NSError *err))block;
- (UIImage *)fetchImageFromDisk:(NSString *)key updatedAfter:(NSDate *)date;

@end
