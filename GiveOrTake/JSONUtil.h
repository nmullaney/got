//
//  JSONUtil.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/3/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtil : NSObject

+ (id)normalizeJSONValue:(id)value toClass:(Class)class;

@end
