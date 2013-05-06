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

@class GOTItemState;

@interface GOTItem : NSObject <JSONSerializable>

- (UIImage *)image;
- (void)setThumbnailDataFromImage:(UIImage *)i;
- (UIImage *)imageFromPicture:(UIImage *)i;
- (NSDictionary *)uploadDictionary;

- (BOOL)isEmpty;
- (BOOL)matchesText:(NSString *)searchText;

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, strong) NSDate *dateUpdated;
@property (nonatomic) GOTItemState *state;
// This is the user that is promised or has taken an item
@property (nonatomic, strong) NSNumber *stateUserID;
@property (nonatomic) BOOL hasUnsavedChanges;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic) BOOL imageNeedsUpload;

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *numMessagesSent;

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) NSData *thumbnailData;

@end
