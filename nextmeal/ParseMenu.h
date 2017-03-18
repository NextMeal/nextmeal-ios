//
//  ParseMenu.h
//  nextmeal
//
//  Created by Anson Liu on 3/12/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Menu.h"

#import "ParseMenuProtocol.h"

@interface ParseMenu : NSObject

+ (Menu *)retrieveSavedMenus;
+ (void)retrieveMenusWithDelegate:(id<ParseMenuProtocol>)delegate;

@end
