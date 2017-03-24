//
//  ParseMenu.h
//  nextmeal
//
//  Created by Anson Liu on 3/12/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

#import "Menu.h"

#import "ParseMenuProtocol.h"
#import <UIKit/UIKit.h>

@interface ParseMenu : NSObject

+ (Menu *)retrieveSavedMenusWithError:(NSError **)error;
+ (void)retrieveMenusWithDelegate:(id<ParseMenuProtocol>)delegate withOriginType:(NMRequestOriginType)originType;

@end
