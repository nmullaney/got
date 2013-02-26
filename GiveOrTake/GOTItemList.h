//
//  GOTItemList.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"

@interface GOTItemList : NSObject <JSONSerializable>

@property (nonatomic, strong) NSMutableArray *items;

@end
