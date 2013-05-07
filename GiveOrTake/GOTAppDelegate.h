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

- (void)setupLoginControllerWithURL:(NSURL *)url;
- (void)setupTabBarControllersWithURL:(NSURL *)url;
- (void)setupWelcomeController;
- (void)logout;

void uncaughtExceptionHandler(NSException *exception);

@end
