//
//  BackgroundFetchMenu.m
//  nextmeal
//
//  Created by Anson Liu on 3/22/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "BackgroundFetchMenu.h"

#import "ParseMenuProtocol.h"

#import "ParseMenu.h"

@interface BackgroundFetchMenu () <ParseMenuProtocol>

@property void (^backgroundFetchCompletionHandler)(UIBackgroundFetchResult);

@end

@implementation BackgroundFetchMenu

#pragma mark - ParseMenuProtocol methods

- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
    if (error) {
        NSLog(@"Error when doing background fetch for menu. %@", error.localizedDescription);
        _backgroundFetchCompletionHandler(UIBackgroundFetchResultFailed);
    } else {
        NSLog(@"Background fetch for menu successful.");
        _backgroundFetchCompletionHandler(UIBackgroundFetchResultNewData);
    }
}

#pragma mark - Instance background fetch method

//This must be an instance method just to conform with the PraseMenuProtocol method. Keep it simple and save the completionHandler as a property to access in the delegate instead of creating another protocol to pass the completionHandler.
- (void)retrieveMenusWithBackgroundFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    _backgroundFetchCompletionHandler = completionHandler;
    [ParseMenu retrieveMenusWithDelegate:self withOriginType:NMBackground];
}


@end
