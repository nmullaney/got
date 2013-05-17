//
//  GOTItem.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItem.h"

#import "GOTImageStore.h"
#import "GOTItemsStore.h"
#import "GOTActiveUser.h"
#import "GOTItemState.h"
#import "GOTConstants.h"

@implementation GOTItem

@synthesize itemID, name, desc, imageKey, imageNeedsUpload, thumbnail, thumbnailData, thumbnailURL, userID, numMessagesSent,
    distance, imageURL, state, stateUserID;

- (id)initWithName:(NSString *)itemName
       description:(NSString *)itemDescription
{
    self = [super init];
    if (self) {
        [self setName:itemName];
        [self setDesc:itemDescription];
        [self setUserID:[[GOTActiveUser activeUser] userID]];
        [self setState:[GOTItemState DRAFT]];
        [self setHasUnsavedChanges:YES];
        [self setImageNeedsUpload:NO];
    }
    return self;
}

- (id)init
{
    return [self initWithName:nil description:nil];
}

// Returns true if this item has no data
- (BOOL)isEmpty
{
    NSLog(@"Name: %@", [self name]);
    if([self itemID] || [self name] || [self desc] || [self thumbnailData]) {
        return NO;
    }
    return YES;
}

// Returns true if the search text is in the name or description
- (BOOL)matchesText:(NSString *)searchText
{
    if (!searchText) {
        // Everything matches nil
        return YES;
    }
    NSRange matchedRange = [[self name] rangeOfString:searchText options:NSCaseInsensitiveSearch];
    if (matchedRange.location != NSNotFound) {
        return YES;
    }
    if ([self desc]) {
        matchedRange = [[self desc] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (matchedRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

// Make sure an empty string is treated as nil
- (void)setDesc:(NSString *)newDesc
{
    if ([newDesc isEqualToString:@""]) {
        desc = nil;
    } else {
        desc = newDesc;
    }
}

- (NSURL *)itemURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"/item.php?itemID=%@", [self itemID]] relativeToURL:[GOTConstants baseWebURL]];
}

#pragma mark load from dictionary

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    [self setItemID:[d objectForKey:@"id"]];
    [self setUserID:[d objectForKey:@"userID"]];
    [self setName:[d objectForKey:@"name"]];
    // Descriptions may be empty.  This will be a NULL
    // on the server, but we should treat it as a nil
    id ddesc = [d objectForKey:@"description"];
    if (ddesc == (id)[NSNull null]) {
        desc = nil;
    } else {
        desc = ddesc;
    }
    
    id tnURLString = [d objectForKey:@"thumbnailURL"];
    if (tnURLString) {
        if (tnURLString == (id)[NSNull null]) {
            thumbnailURL = nil;
        } else {
          thumbnailURL = [NSURL URLWithString:(NSString *)tnURLString];
        }
    }
    
    id imageURLString = [d objectForKey:@"imageURL"];
    if (imageURLString) {
        if (imageURLString == (id)[NSNull null]) {
            imageURL = nil;
        } else {
            // For items we load from the web, we'll use their itemID
            // as the image key.  This might mean that we'll have doubles
            // for images the user has uploaded, but it ensures we'll never
            // have collisions
            [self setImageKey:[NSString stringWithFormat:@"%@", [d objectForKey:@"id"]]];
            imageURL = [NSURL URLWithString:(NSString *)imageURLString];
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // The server is on GMT
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];    
    [self setDatePosted:[formatter dateFromString:[d objectForKey:@"dateCreated"]]];
    [self setDateUpdated:[formatter dateFromString:[d objectForKey:@"dateUpdated"]]];
    
    [self setState:[GOTItemState getValue:[d objectForKey:@"state"]]];
    
    id dstateUserID = [d objectForKey:@"stateUserID"];
    if (dstateUserID == (id)[NSNull null]) {
        [self setStateUserID:nil];
    } else {
        [self setStateUserID:[d objectForKey:@"stateUserID"]];
    }
    
    if ([d objectForKey:@"distance"]) {
        [self setDistance:[d objectForKey:@"distance"]];
    }
    
    if ([d objectForKey:@"numMessagesSent"]) {
        [self setNumMessagesSent:[d objectForKey:@"numMessagesSent"]];
    }
    
    [self setHasUnsavedChanges:NO];
}

// Converts the item's data into key/value pairs
// for upload to the server.
- (NSDictionary *)uploadDictionary
{
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    if ([self itemID]) {
        [objs addObject:[self itemID]];
        [keys addObject:@"item_id"];
    }
    if ([self name]) {
        [objs addObject:[self name]];
        [keys addObject:@"name"];
    }
    if ([self desc]) {
        [objs addObject:[self desc]];
        [keys addObject:@"desc"];
    }
    if ([self state]) {
        [objs addObject:[self state]];
        [keys addObject:@"state"];
    }
    if ([self stateUserID]) {
        [objs addObject:[self stateUserID]];
        [keys addObject:@"state_user_id"];
    } else {
        // TODO: handle this on web side
        [objs addObject:@"NULL"];
        [keys addObject:@"state_user_id"];
    }
    if ([self userID]) {
        [objs addObject:[self userID]];
        [keys addObject:@"user_id"];
    } else {
        NSLog(@"ERROR: uh oh, no user ID");
    }
    return [NSDictionary dictionaryWithObjects:objs forKeys:keys];
}

#pragma mark -
#pragma mark image methods

// Returns the image for this item from the store
- (UIImage *)image
{
    if ([self imageKey]) {
        return [[GOTImageStore sharedStore] imageForKey:[self imageKey]];
    }
    return nil;
}

- (UIImage *)thumbnail
{
    if (!thumbnailData) {
        return nil;
    }
    if (!thumbnail) {
        thumbnail = [UIImage imageWithData:thumbnailData];
    }
    return thumbnail;
}

-(void)setThumbnailDataFromImage:(UIImage *)i
{
    CGSize origImageSize = [i size];
    
    float thumbnailPixels = 80 / [[UIScreen mainScreen] scale];
    CGRect thumbRect = CGRectMake(0, 0, thumbnailPixels, thumbnailPixels);
    
    // Figure out a good scaling ratio
    float ratio = MAX(thumbRect.size.width / origImageSize.width,
                      thumbRect.size.height / origImageSize.height);
    
    // Create a transparent bitmap context
    UIGraphicsBeginImageContextWithOptions(thumbRect.size, NO, 0.0);
    
    // Create a rounded rect path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:thumbRect cornerRadius:5.0];
    
    // All drawing should clip to this rectangle
    [path addClip];
    
    // Center the image in the rectangle
    CGRect workRect;
    workRect.size.width = ratio * origImageSize.width;
    workRect.size.height = ratio * origImageSize.height;
    workRect.origin.x = (thumbRect.size.width - workRect.size.width) / 2.0;
    workRect.origin.y = (thumbRect.size.height - workRect.size.height) / 2.0;
    
    [i drawInRect:workRect];
    
    // Get the image from the image context
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:smallImage];
    
    // PNG data
    NSData *data = UIImagePNGRepresentation(smallImage);
    [self setThumbnailData:data];
    
    // cleanup
    UIGraphicsEndImageContext();
}

- (UIImage *)imageFromPicture:(UIImage *)i
{

    CGSize origImageSize = [i size];
    
    float imagePixels = 1024 / [[UIScreen mainScreen] scale];
    CGRect imageRect = CGRectMake(0, 0, imagePixels, imagePixels);
    
    // Figure out a good scaling ratio
    float ratio = MAX(imageRect.size.width / origImageSize.width,
                      imageRect.size.height / origImageSize.height);
    
    // Create a transparent bitmap context
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0);
    
    // Create a rounded rect path
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
    
    // All drawing should clip to this rectangle
    [path addClip];
    
    // Center the image in the rectangle
    CGRect workRect;
    workRect.size.width = ratio * origImageSize.width;
    workRect.size.height = ratio * origImageSize.height;
    workRect.origin.x = (imageRect.size.width - workRect.size.width) / 2.0;
    workRect.origin.y = (imageRect.size.height - workRect.size.height) / 2.0;
    
    [i drawInRect:workRect];
    
    // Get the image from the image context
    UIImage *sqImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // cleanup
    UIGraphicsEndImageContext();
    return sqImage;
}

#pragma mark -

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %@, Name:%@, Desc:%@", [self itemID], [self name], [self desc]];
}

@end
