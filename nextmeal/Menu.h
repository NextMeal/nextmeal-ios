//
//  Menu.h
//  nextmeal
//
//  Created by Anson Liu on 3/13/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Week.h"

@interface Menu : NSObject

@property (readonly) NSArray<Week *> *weeks;

- (void)addWeek:(Week *)week;
- (void)updateWeekIndex:(NSInteger)index withWeek:(Week *)week;

@end
