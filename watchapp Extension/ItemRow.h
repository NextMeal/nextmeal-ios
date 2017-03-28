//
//  ItemRow.h
//  nextmeal
//
//  Created by Anson Liu on 3/27/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@import WatchKit;

@interface ItemRow : NSObject
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *itemTitleLabel;

@end
