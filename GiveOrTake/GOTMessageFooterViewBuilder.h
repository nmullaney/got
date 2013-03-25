//
//  GOTMessageFooterViewBuilder.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTMessageFooterViewBuilder : NSObject

- (id)initWithFrame:(CGRect)f title:(NSString *)ttl message:(NSString *)msg;

@property (nonatomic, readonly) UIView *view;
@property (nonatomic) CGRect frame;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@end
