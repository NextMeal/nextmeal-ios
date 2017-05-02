//
//  AppDelegate.m
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AppDelegate.h"

#import "Constants.h"
#import "BackgroundFetchMenu.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Background fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[BackgroundFetchMenu new] retrieveMenusWithBackgroundFetchCompletionHandler:completionHandler];
}

#pragma mark - URL open

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"open url %@", url.absoluteString);
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
    NSMutableDictionary *queryItemDict = [NSMutableDictionary dictionaryWithCapacity:components.queryItems.count];
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        [queryItemDict setObject:queryItem.value forKey:queryItem.name];
    }
    
    if ([[queryItemDict allKeys] containsObject:kSelectedViewKey]) {
        NSUInteger selectedIndex = 0;
        if ([[queryItemDict objectForKey:kSelectedViewKey] isEqual:kSelectedViewNextMeal])
            selectedIndex = 0;
        else if ([[queryItemDict objectForKey:kSelectedViewKey] isEqual:kSelectedViewExtendedMenu])
            selectedIndex = 1;
        else if ([[queryItemDict objectForKey:kSelectedViewKey] isEqual:kSelectedViewExtras])
            selectedIndex = 2;
        
        //Must call unwind notification before loading detail view notification because the segue will get messed up if the unwinding detail view is in background
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnwindDetailView object:self userInfo:nil];
        NSDictionary *userInfo = @{kSelectedViewIndexKey:[NSNumber numberWithUnsignedInteger:selectedIndex]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadView object:self userInfo:userInfo];
    }
    
    if ([[queryItemDict allKeys] containsObject:kSelectedSectionKey]) {
        NSUInteger selectedSection = 0;
        selectedSection = (NSUInteger)[[queryItemDict objectForKey:kSelectedSectionKey] integerValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnwindDetailView object:self userInfo:nil];
        NSDictionary *userInfo = @{kSelectedSectionKey:[NSNumber numberWithUnsignedInteger:selectedSection]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadSection object:self userInfo:userInfo];
    }
    
    
    return YES;
}

#pragma mark - Application lifecycle methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Fabric with:@[[Crashlytics class]]];
    
    //Set settings bundle defaults
    //https://clang.llvm.org/docs/ObjectiveCLiterals.html for use of literals for integers
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kSettingsP2PKey : [NSNumber numberWithBool:YES], kSettingsP2PShareKey : [NSNumber numberWithBool:YES], kP2PSeedTotal : @0, kP2PLeechTotal : @0, kNMMultipeerDeviceIdBlacklistKey : [NSArray<NSString *> new]}];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
