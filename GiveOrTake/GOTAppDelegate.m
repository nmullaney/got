//
//  GOTAppDelegate.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTAppDelegate.h"
#import "GOTLoginViewController.h"
#import "GOTWelcomeViewController.h"
#import "GOTItemsViewController.h"
#import "GOTOffersViewController.h"
#import "GOTProfileViewController.h"
#import "GOTSettings.h"
#import "GOTUserStore.h"
#import "GOTItemsStore.h"
#import "GOTActiveUser.h"
#import "GOTConstants.h"

#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>

@implementation GOTAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // Startup the Hockey system
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"778954ac708922955173508ac7d0cd24"
                                                           delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // Initialize the settings
    [[GOTSettings instance] setupDefaults];
    
    if ([self loggedIn]) {
        [self setupTabBarControllersWithURL:nil];
    } else {
        [self setupLoginControllerWithURL:nil];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

- (BOOL)loggedIn
{
    return FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded &&
    [[GOTActiveUser activeUser] token];
}

- (void)setupLoginControllerWithURL:(NSURL *)url
{
    GOTLoginViewController *loginvc = [[GOTLoginViewController alloc] init];
    [loginvc setPostLoginBlock:^{
        if ([[GOTActiveUser activeUser] isNewUser]) {
            [self setupWelcomeController];
        } else {
            [self setupTabBarControllersWithURL:url];
        }
    }];
    [[self window] setRootViewController:loginvc];
}

- (void)setupTabBarControllersWithURL:(NSURL *)url
{
    // My Offers Controller
    GOTOffersViewController *ovc = [[GOTOffersViewController alloc] init];
    UINavigationController *offerNav = [[UINavigationController alloc] initWithRootViewController:ovc];
    UITabBarItem *offerItem = [[UITabBarItem alloc] init];
    [offerItem setTitle:@"Give"];
    [offerItem setFinishedSelectedImage:[UIImage imageNamed:@"give-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"give"]];
    [offerNav setTabBarItem:offerItem];
    
    // Free Items Controller
    GOTItemsViewController *ivc = [[GOTItemsViewController alloc] init];
    UINavigationController *freeNav = [[UINavigationController alloc] initWithRootViewController:ivc];
    UITabBarItem *freeItem = [[UITabBarItem alloc] init];
    [freeItem setTitle:@"Take"];
    [freeItem setFinishedSelectedImage:[UIImage imageNamed:@"take-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"take"]];
    [freeNav setTabBarItem:freeItem];
    
    // Profile Controller
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:@"GOTProfileViewStoryboard"
                                                                bundle:nil];
    GOTProfileViewController *pvc = [profileStoryboard instantiateInitialViewController];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:pvc];
    UITabBarItem *profileItem = [[UITabBarItem alloc] init];
    [profileItem setTitle:@"Profile"];
    [profileItem setFinishedSelectedImage:[UIImage imageNamed:@"profile-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"profile"]];
    [profileNav setTabBarItem:profileItem];
    
    // Tab Bar
    UITabBarController *tvc = [[UITabBarController alloc] init];
    [tvc addChildViewController:offerNav];
    [tvc addChildViewController:freeNav];
    [tvc addChildViewController:profileNav];
    // Show free items first
    [tvc setSelectedIndex:1];
    
    // Setup default color scheme
    [[UINavigationBar appearance] setTintColor:[GOTConstants defaultNavBarColor]];
    [[UIToolbar appearance] setTintColor:[GOTConstants defaultNavBarColor]];
    
    // Setup default fonts
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: [GOTConstants defaultVeryLargeFont]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [GOTConstants barButtonItemFont]} forState:UIControlStateNormal];
    [[UITextField appearance] setFont:[GOTConstants defaultMediumFont]];
    
    if (url) {
        if ([[url host] isEqual:@"freeItem"]) {
            [tvc setSelectedIndex:1];
            NSString *freeItemIDStr = [[self parseURLQuery:url] objectForKey:@"itemID"];
            NSNumber *freeItemID = [NSNumber numberWithInt:[freeItemIDStr intValue]];
            [ivc setFreeItemID:freeItemID];
        } 
    }
    
    [[self window] setRootViewController:tvc];
}

- (NSDictionary *)parseURLQuery:(NSURL *)url
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    NSArray *components = [[url query] componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray *keyVals = [component componentsSeparatedByString:@"="];
        if ([keyVals count] == 2) {
            [values setValue:[keyVals objectAtIndex:1] forKey:[keyVals objectAtIndex:0]];
        } else {
            [values setValue:nil forKey:[keyVals objectAtIndex:0]];
        }
    }
    return values;
}

- (void)setupWelcomeController
{
    GOTWelcomeViewController *wvc = [[GOTWelcomeViewController alloc] init];
    [[self window] setRootViewController:wvc];
}

- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [GOTActiveUser logout];
    [[GOTItemsStore sharedStore] clearItems];
    [self setupLoginControllerWithURL:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[url scheme] hasPrefix:@"fb"]) {
        return [FBSession.activeSession handleOpenURL:url];
    } else if ([[url scheme] hasPrefix:@"giveortakeapp"]) {
        if ([self loggedIn]) {
            [self setupTabBarControllersWithURL:url];
        } else {
            [self setupLoginControllerWithURL:url];
        }
        return YES;
    } else {
        NSLog(@"Unexpected URL: %@", url);
        return NO;
    }
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
    
    // Don't save the user before we've logged in (we'll enter background as part of the FB login process)
    if ([[[GOTActiveUser activeUser] userID] intValue] != 0) {
        [GOTActiveUser save];
    }
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

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"Unhandled exception: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@end