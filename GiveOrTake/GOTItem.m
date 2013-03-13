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
#import "GOTUserStore.h"

@implementation GOTItem

@synthesize itemID, name, desc, imageKey, thumbnail, thumbnailData, thumbnailURL, userID, imageURL, state;

- (id)initWithName:(NSString *)itemName
       description:(NSString *)itemDescription
{
    self = [super init];
    if (self) {
        [self setName:itemName];
        [self setDesc:itemDescription];
        [self setDatePosted:[NSDate date]];
        [self setUserID:[[GOTUserStore sharedStore] activeUserID]];
        [self setState:DRAFT];
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
    if([self itemID] || [self name] || [self desc] || [self thumbnailData]) {
        return NO;
    }
    return YES;
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

- (ItemState)itemStateForString:(NSString *)s
{
    if ([s isEqualToString:@"DRAFT"]) {
        return DRAFT;
    } else if ([s isEqualToString:@"AVAILABLE"]) {
        return AVAILABLE;
    } else if ([s isEqualToString:@"PENDING"]) {
        return PENDING;
    } else if ([s isEqualToString:@"TAKEN"]) {
        return TAKEN;
    } else if ([s isEqualToString:@"DELETED"]) {
        return DELETED;
    }
    return nil;
}

- (NSString *)stringForItemState:(ItemState)s
{
    switch (s) {
        case DRAFT:
            return @"DRAFT";
        case AVAILABLE:
            return @"AVAILABLE";
        case PENDING:
            return @"PENDING";
        case TAKEN:
            return @"TAKEN";
        case DELETED:
            return @"DELETED";
            
        default:
            return @"UNKNOWN";
    }
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
    [self setDatePosted:[d objectForKey:@"dateCreated"]];
    
    id tnURLString = [d objectForKey:@"thumbnailURL"];
    if (tnURLString) {
        thumbnailURL = [NSURL URLWithString:(NSString *)tnURLString];
    }
    
    id imageURLString = [d objectForKey:@"imageURL"];
    if (imageURLString) {
        imageURL = [NSURL URLWithString:(NSString *)imageURLString];
    }
    
    id dateCreated = [d objectForKey:@"dateCreated"];
    if (dateCreated) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [self setDatePosted:[formatter dateFromString:dateCreated]];
    }
    
    id itemState = [d objectForKey:@"state"];
    if (itemState) {
        [self setState:[self itemStateForString:itemState]];
    }
}

// Converts the item's data into key/value pairs
// for upload to the server.
- (NSDictionary *)uploadDictionary
{
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    if ([self itemID]) {
        [objs addObject:[self itemID]];
        [keys addObject:@"id"];
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
        [objs addObject:[self stringForItemState:[self state]]];
        [keys addObject:@"state"];
    }
    if ([self userID]) {
        [objs addObject:[self userID]];
        [keys addObject:@"userID"];
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

// This is just for generating test data
+ (NSArray *)randomItems:(int) count;
{
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        GOTItem *item = [GOTItem createRandomItem];
        [items addObject:item];
    }
    return items;
}

+(id)createRandomItem
{
    NSArray *nouns = [[NSArray alloc] initWithObjects:@"Lamp", @"Table", @"Hat", @"Plant", @"Shoes", @"Sofa", nil];
    NSArray *adjs = [[NSArray alloc] initWithObjects:@"Fuzzy", @"Blue", @"Broken", @"Silly", @"Fluffy", @"Large", @"Poofy", nil];
    int nounIdx = rand() % [nouns count];
    int adjIdx = rand() % [adjs count];
    
    NSString *noun = [nouns objectAtIndex:nounIdx];
    NSString *adj = [adjs objectAtIndex:adjIdx];
    
    NSString *randomName = [[NSString alloc] initWithFormat:@"%@ %@", adj, noun];
    
    NSString *randomDesc = [[NSString alloc] initWithFormat:@"This %@ is %@", noun, adj];
    
    return [[GOTItem alloc] initWithName:randomName
                             description:randomDesc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name:%@, Desc:%@", [self name], [self desc]];
}

@end
