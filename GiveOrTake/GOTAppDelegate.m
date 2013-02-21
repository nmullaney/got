//
//  GOTAppDelegate.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTAppDelegate.h"
#import "GOTItemsViewController.h"
#import "GOTToolbarViewController.h"
#import "GOTOffersViewController.h"
#import "GOTProfileViewController.h"
#import "GOTSettings.h"

@implementation GOTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Initialize the settings
    [[GOTSettings instance] setupDefaults];
    
    // Free Items Controller
    GOTItemsViewController *ivc = [[GOTItemsViewController alloc] init];
    UINavigationController *freeNav = [[UINavigationController alloc] initWithRootViewController:ivc];
    UITabBarItem *freeItem = [[UITabBarItem alloc] initWithTitle:@"Free Items" image:nil tag:0];
    [freeNav setTabBarItem:freeItem];
    
    // My Offers Controller
    GOTOffersViewController *ovc = [[GOTOffersViewController alloc] init];
    UINavigationController *offerNav = [[UINavigationController alloc] initWithRootViewController:ovc];
    UITabBarItem *offerItem = [[UITabBarItem alloc] initWithTitle:@"My Offers" image:nil tag:1];
    [offerNav setTabBarItem:offerItem];
    
    // Profile Controller
    GOTProfileViewController *pvc = [[GOTProfileViewController alloc] init];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:pvc];
    UITabBarItem *profileItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:nil tag:2];
    [profileNav setTabBarItem:profileItem];
    
    // Tab Bar
    UITabBarController *tvc = [[UITabBarController alloc] init];
    [tvc addChildViewController:freeNav];
    [tvc addChildViewController:offerNav];
    [tvc addChildViewController:profileNav];
    
    [[self window] setRootViewController:tvc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
