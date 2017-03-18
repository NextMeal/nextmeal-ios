//
//  ParseMenuProtocol.h
//  nextmeal
//
//  Created by Anson Liu on 3/14/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Menu;

@protocol ParseMenuProtocol <NSObject>

- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withURLResponse:(NSURLResponse *)response withError:(NSError *)error;

@end
