//
//  GOTAppDelegate.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTAppDelegate.h"
#import "GOTLoginViewController.h"
#import "GOTItemsViewController.h"
#import "GOTOffersViewController.h"
#import "GOTProfileViewController.h"
#import "GOTSettings.h"
#import "GOTUserStore.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation GOTAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Initialize the settings
    [[GOTSettings instance] setupDefaults];
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded &&
        [[GOTSettings instance] activeFacebookUserID]) {
        // TODO: should we wait for successful load of active user before
        // loading the tabs?
        NSLog(@"logged in, loading user");
        [[GOTUserStore sharedStore] loadActiveUserWithCompletion:^(id user, NSError *err) {
            if (user) {
                [self setupTabBarControllers];
            } else {
                NSLog(@"Severe error: cannot get user");
                [self setupLoginController];
            }
        }];
    } else {
        NSLog(@"not logged in");
        [self setupLoginController];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupLoginController
{
    GOTLoginViewController *loginvc = [[GOTLoginViewController alloc] init];
    [[self window] setRootViewController:loginvc];
}

- (void)setupTabBarControllers
{
    // My Offers Controller
    GOTOffersViewController *ovc = [[GOTOffersViewController alloc] init];
    UINavigationController *offerNav = [[UINavigationController alloc] initWithRootViewController:ovc];
    UITabBarItem *offerItem = [[UITabBarItem alloc] initWithTitle:@"Give" image:nil tag:0];
    [offerNav setTabBarItem:offerItem];
    
    // Free Items Controller
    GOTItemsViewController *ivc = [[GOTItemsViewController alloc] init];
    UINavigationController *freeNav = [[UINavigationController alloc] initWithRootViewController:ivc];
    UITabBarItem *freeItem = [[UITabBarItem alloc] initWithTitle:@"Take" image:nil tag:1];
    [freeNav setTabBarItem:freeItem];
    
    // Profile Controller
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:@"GOTProfileViewStoryboard"
                                                                bundle:nil];
    GOTProfileViewController *pvc = [profileStoryboard instantiateInitialViewController];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:pvc];
    UITabBarItem *profileItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:nil tag:2];
    [profileNav setTabBarItem:profileItem];
    
    // Tab Bar
    UITabBarController *tvc = [[UITabBarController alloc] init];
    [tvc addChildViewController:offerNav];
    [tvc addChildViewController:freeNav];
    [tvc addChildViewController:profileNav];
    
    [[self window] setRootViewController:tvc];
}

- (void)logout
{
    NSLog(@"logout and clear token info");
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[GOTSettings instance] setActiveFacebookUserID:nil];
    [[GOTUserStore sharedStore] setActiveUser:nil];
    [self setupLoginController];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
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
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

@end
