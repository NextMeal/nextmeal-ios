//
//  BackgroundFetchMenu.h
//  nextmeal
//
//  Created by Anson Liu on 3/22/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

#import "Menu.h"

#import <UIKit/UIKit.h>

@interface BackgroundFetchMenu : NSObject

- (void)retrieveMenusWithBackgroundFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
