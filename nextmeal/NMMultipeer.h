//
//  NMMultipeer.h
//  nextmeal
//
//  Created by Anson Liu on 3/22/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ParseMenuProtocol.h"

@class Menu;

@interface NMMultipeer : NSObject

@property id<ParseMenuProtocol> delegate;

- (void)startAdvertisingAndBrowsingWithMenu:(Menu *)menu andDate:(NSDate *)date;
- (void)stopAdvertisingAndBrowsing;

@end
