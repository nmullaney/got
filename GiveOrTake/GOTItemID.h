//
//  GOTItemID.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/27/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"

@interface GOTItemID : NSObject <JSONSerializable>

@property (nonatomic) NSInteger itemID;

@end
