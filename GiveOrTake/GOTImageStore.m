//
//  GOTImageStore.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTImageStore.h"

#import "GOTConnection.h"
#import "GOTMutableURLPostRequest.h"
#import "GOTConstants.h"
#import "GOTItem.h"

@implementation GOTImageStore

+ (GOTImageStore *)sharedStore
{
    static GOTImageStore *imageStore = nil;
    if (!imageStore) {
        imageStore = [[GOTImageStore alloc] init];
    }
    return imageStore;
}

+ (NSString *)createImageKey
{
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *strID = (NSString *)CFBridgingRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    return strID;
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
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [imageCache setObject:i forKey:s];
}

// Get image from the in-memory cache
- (UIImage *)imageForKey:(NSString *)s
{
    return [imageCache objectForKey:s];
}

// Get the image from the in-memory cache or disk
// If the disk image is older than the date, delete it and return nil
- (UIImage *)imageForKey:(NSString *)s updatedAfter:(NSDate *)date
{
    UIImage *memCachedImage = [imageCache objectForKey:s];
    if (!memCachedImage) {
        NSLog(@"Could not find memCachedImage: looking at disk");
        UIImage *fileCachedImage = [self fetchImageFromDisk:s updatedAfter:date];
        if (fileCachedImage) {
            NSLog(@"Fetched image from filesystem");
            [imageCache setObject:fileCachedImage forKey:s];
            return fileCachedImage;
        }
    } else {
        NSLog(@"Found memCachedImage");
    }
    return memCachedImage;
}

- (void)deleteImageForKey:(NSString *)s
{
    if (!s) {
        return;
    }
    [imageCache removeObjectForKey:s];
    NSString *filePath = [self filePathForKey:s];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"Clearing %d images", [imageCache count]);
    [self saveCacheToDisk];
    [imageCache removeAllObjects];
}

+ (NSString *)imageCachePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    // There is only one document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:TRUE
                                attributes:nil
                                     error:nil];
    }
    return path;
}

- (NSString *)filePathForKey:(NSString *)key
{
    NSString *directory = [GOTImageStore imageCachePath];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", key];
    return [directory stringByAppendingPathComponent:fileName];
}

- (void)saveCacheToDisk
{
    [self deleteOldImagesOnDisk];
    [imageCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        UIImage *image = (UIImage *) obj;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:[self filePathForKey:key]
                             contents:imageData attributes:nil];
    }];
}

- (void)deleteOldImagesOnDisk
{
    //NSLog(@"Looking for old images to delete");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [GOTImageStore imageCachePath];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    for (NSString *file in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        //NSLog(@"Check file %@", filePath);
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:filePath error:nil];
        // Delete if the file is older than one week
        //NSLog(@"Interval: %f", [[fileAttr fileCreationDate] timeIntervalSinceNow]);
        if ([[fileAttr fileCreationDate] timeIntervalSinceNow] < -604800) {
            //NSLog(@"Removing file for: %@", filePath);
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

- (UIImage *)fetchImageFromDisk:(NSString *)key updatedAfter:(NSDate *)date
{
    NSLog(@"Looking for image updated after: %@", date);
    NSString *filePath = [self filePathForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSLog(@"Image updated on: %@", [fileAttr fileModificationDate]);
        if ([[fileAttr fileModificationDate] timeIntervalSinceDate:date] < 0) {
            // Image is out of date
            NSLog(@"Image is out of date");
            [fileManager removeItemAtPath:filePath error:nil];
            return nil;
        } 
        NSData *imageData = [fileManager contentsAtPath:filePath];
        NSLog(@"Creating image from data");
        UIImage *image = [UIImage imageWithData:imageData];
        return image;
    } else {
        NSLog(@"No file at %@", filePath);
    }
    return nil;
}

- (void)uploadImageForItem:(GOTItem *)item
{
    if (![item imageNeedsUpload]) {
        return;
    }
    UIImage *image = [self imageForKey:[item imageKey]];
    NSData *jpgData = UIImageJPEGRepresentation(image, 0.8);
    
    
    NSURL *url = [NSURL URLWithString:@"/item/image.php" relativeToURL:[GOTConstants baseURL]];
    NSDictionary *formData = [NSDictionary dictionaryWithObject:[item itemID]
                                                         forKey:@"item_id"];
    NSDictionary *imageData = [NSDictionary
                               dictionaryWithObjects:[NSArray arrayWithObjects:@"image",@"image.jpg",@"image/jpg",jpgData, nil]
                               forKeys:[NSArray arrayWithObjects:@"name",@"filename",@"contentType",@"data",nil]
                               ];

    
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url formData:formData imageData:imageData];
    GOTConnection *connection = [[GOTConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:^(id result, NSError *err) {
        [item setImageNeedsUpload:NO];
        NSLog(@"result = %@", result);
    }];
    [connection start];
}

- (void)fetchImageForItem:(GOTItem *)item withCompletion:(void (^)(id, NSError *))block
{
    NSLog(@"Fetching image");
    if ([item image]) {
        NSLog(@"Found image in item object");
        block([item image], nil);
        return;
    }
    
    UIImage *image = nil;
    if ([item imageKey]) {
        NSLog(@"Found image key: attempting to load image from cache");
        image = [self imageForKey:[item imageKey] updatedAfter:[item dateUpdated]];
    }
    if (image) {
        NSLog(@"Loaded image from store cache");
        block(image, nil);
        return;
    }
    
    if ([item imageURL]) {
        NSLog(@"found image url: %@ fetching it from the web", [item imageURL]);
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[item imageURL]];
        GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
        [conn setCompletionBlock:^(id imageData, NSError *err) {
            if (err) {
                NSLog(@"Got error: %@", err);
                block(nil, err);
                return;
            } else if (imageData) {
                NSLog(@"Got image data from the web");
                UIImage *image = [UIImage imageWithData:imageData];
                if (!image) {
                    NSLog(@"Error: failed to create image from data");
                    block(nil, nil);
                    return;
                }
                NSString *imageKey = [item imageKey];
                [self setImage:image forKey:imageKey];
                block(image, nil);
                return;
            }
        }];
        [conn start];
    } else {
      NSLog(@"Did not find image, no imageURL");
      block(nil, nil);
    }
}

@end
