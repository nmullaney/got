//
//  GOTSingleItemView.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem;

@interface GOTSingleItemView : UIView
{
    UILabel *descLabel;
    UIImageView *imageView;
    UILabel *dateLabel;
}

@property (nonatomic, strong) GOTItem *item;

@end
