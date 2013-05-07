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
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
    __weak IBOutlet UILabel *pleaseLoginLabel;
    FBLoginView *loginView;
    BOOL loggingIn;
}

- (void)showLoggingIn;
- (void)showCanLogIn;

@property (nonatomic) BOOL loggingIn;
@property (nonatomic, copy) void (^postLoginBlock)(void);

@end
