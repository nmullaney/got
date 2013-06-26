//
//  GOTLoginViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/1/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface GOTLoginViewController : UIViewController <FBLoginViewDelegate>
{
    __weak IBOutlet UIImageView *backgroundImageView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
    FBLoginView *loginView;
    BOOL loggingIn;
}

- (void)showLoggingIn;
- (void)showCanLogIn;
- (BOOL)isLongScreen;

@property (nonatomic) BOOL loggingIn;
@property (nonatomic, copy) void (^postLoginBlock)(void);

@end
