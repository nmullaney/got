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
    return (__bridge NSString *)newUniqueIDString;
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

- (void)uploadImageForKey:(NSString *)s withItemID:(NSNumber *)itemID
{
    UIImage *image = [self imageForKey:s];
    NSData *jpgData = UIImageJPEGRepresentation(image, 0.8);
    
    
    NSURL *url = [NSURL URLWithString:@"/api/item/image.php" relativeToURL:[GOTConstants baseURL]];
    NSDictionary *formData = [NSDictionary dictionaryWithObject:itemID
                                                         forKey:@"id"];
    NSDictionary *imageData = [NSDictionary
                               dictionaryWithObjects:[NSArray arrayWithObjects:@"image",@"image.jpg",@"image/jpg",jpgData, nil]
                               forKeys:[NSArray arrayWithObjects:@"name",@"filename",@"contentType",@"data",nil]
                               ];

    
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url formData:formData imageData:imageData];
    GOTConnection *connection = [[GOTConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:^(id result, NSError *err) {
        NSLog(@"result = %@", result);
    }];
    [connection start];
}

- (void)fetchImageForItem:(GOTItem *)item withCompletion:(void (^)(id, NSError *))block
{
    NSLog(@"Fetching image");
    if ([item image]) {
        NSLog(@"Found image in item");
        block([item image], nil);
        return;
    }
    
    UIImage *image = nil;
    if ([item imageKey]) {
        NSLog(@"Found image key");
        image = [self imageForKey:[item imageKey]];
    }
    if (image) {
        block(image, nil);
        return;
    }
    
    if ([item imageURL]) {
        NSLog(@"found image url");
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[item imageURL]];
        GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
        [conn setCompletionBlock:^(id imageData, NSError *err) {
            if (imageData) {
                NSLog(@"Got image data");
                UIImage *image = [UIImage imageWithData:imageData];
                NSString *imageKey = [GOTImageStore createImageKey];
                [item setImageKey:imageKey];
                [self setImage:image forKey:imageKey];
                block(image, nil);
            }
            if (err) {
                NSLog(@"Got error");
                block(nil, err);
            }
        }];
        [conn start];
    } else {
      NSLog(@"Did not find image");
      block(nil, nil);
    }
}

@end
