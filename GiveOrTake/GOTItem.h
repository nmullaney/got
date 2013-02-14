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

@interface GOTItem : NSObject

+ (NSArray *)randomItems:(int)count;
+ (id)createRandomItem;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate *datePosted;
@property (nonatomic, weak) UIImage *image;

// Eventually, we'll want the location to be taken from the user's profile
// TODO
//@property (nonatomic) CLLocationCoordinate2D location;

@end
