//
//  DetailInterfaceController.m
//  nextmeal
//
//  Created by Anson Liu on 3/28/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "DetailInterfaceController.h"

#import "Constants.h"

@interface DetailInterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *itemTitleLabel;

@end

@implementation DetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [_itemTitleLabel setText:[context objectForKey:kItemTitleKey]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



