//
//  GOTAppDelegate.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setupLoginController;
- (void)setupTabBarControllers;
- (void)logout;

void uncaughtExceptionHandler(NSException *exception);

@end
