//
//  GOTItem.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "JSONSerializable.h"

typedef enum {DRAFT, AVAILABLE, PENDING, TAKEN, DELETED, UNKNOWN} ItemState;

@interface GOTItem : NSObject <JSONSerializable>

- (UIImage *)image;
- (void)setThumbnailDataFromImage:(UIImage *)i;
- (UIImage *)imageFromPicture:(UIImage *)i;
- (NSDictionary *)uploadDictionary;

- (BOOL)isEmpty;

- (ItemState)itemStateForString:(NSString *)s;
- (NSString *)stringForItemState:(ItemState)s;

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, strong) NSDate *dateUpdated;
@property (nonatomic) ItemState state;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic) BOOL imageNeedsUpload;

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSNumber *distance;

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) NSData *thumbnailData;


// Eventually, we'll want the location to be taken from the user's profile
// TODO
//@property (nonatomic) CLLocationCoordinate2D location;

@end
