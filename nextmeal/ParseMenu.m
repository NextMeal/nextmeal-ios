//
//  ParseMenu.m
//  nextmeal
//
//  Created by Anson Liu on 3/12/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "ParseMenu.h"

#import "Constants.h"

#import "ReadWriteLocalData.h"

@implementation ParseMenu

+ (NSData *)readSampleLocalNumber:(NSInteger)number {
    NSString *filename;
    switch (number) {
            case 1:
                filename = kSampleFilename1;
                break;
            case 2:
                filename = kSampleFilename2;
                break;
            default:
            NSLog(@"unhandled sample file number %ld", (long)number);
    }
    return [ReadWriteLocalData readFileFromBundle:filename];
}

+ (Item *)parseItem:(NSObject *)itemData {
    if (![itemData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed itemData is not of kind class NSDictionary.\n%@", itemData);
    }
    
    NSString *itemTitle = [((NSDictionary *)itemData) objectForKey:kMealItemTitleKey];
    
    if (!itemTitle)
        NSLog(@"Parsed itemData has no key %@.\n%@", kMealItemTitleKey, itemData);
    
    if (itemTitle.length == 0)
        //item title is blank, skip
        return nil;
    
    Item *outputItem = [[Item alloc] initWithTitle:itemTitle];
    
    return outputItem;
}

+ (Meal *)parseMeal:(NSObject *)mealData {
    if (![mealData isKindOfClass:[NSArray class]]) {
        NSLog(@"Parsed mealData is not of kind class NSArray.\n%@", mealData);
    }
    
    Meal *outputMeal = [Meal new];
    
    for (NSObject *itemData in (NSArray *)mealData) {
        Item *outputItem = [self parseItem:itemData];
        if (outputItem)
            [outputMeal addItem:outputItem];
    }
    
    return outputMeal;
}

+ (Day *)parseDay:(NSObject *)dayData {
    if (![dayData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed dayData is not of kind class NSDictionary.\n%@", dayData);
    }
    
    Day *outputDay = [Day new];
    
    NSArray<NSString *> *mealKeys = @[kBreakfastKey, kLunchKey, kDinnerKey];
    
    NSArray<NSObject *> *mealDatas = [((NSDictionary *)dayData) objectsForKeys:mealKeys notFoundMarker:[NSObject new]];
    
    for (NSObject *mealData in mealDatas) {
        [outputDay addMeal:[self parseMeal:mealData]];
    }
    
    return outputDay;
}

+ (Week *)parseWeek:(NSObject *)weekData {
    if (![weekData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed object is not of kind class NSDictionary.\n%@", weekData);
    }
    
    NSArray<NSString *> *dayKeys = @[kSundayKey, kMondayKey, kTuesdayKey, kWednesdayKey, kThursdayKey, kFridayKey, kSaturdayKey];
    
    NSArray<NSObject *> *dayDatas = [((NSDictionary *)weekData) objectsForKeys:dayKeys notFoundMarker:[NSObject new]];
    
    Week *outputWeek = [Week new];
    
    for (NSObject *dayData in dayDatas) {
        [outputWeek addDay:[self parseDay:dayData]];
    }
    
    return outputWeek;
}

+ (Week *)parseMenu:(NSData *)menuData {
    NSError *parseError;
    NSObject *weekData = [NSJSONSerialization JSONObjectWithData:menuData options:0 error:&parseError];
    
    if (parseError)
        NSLog(@"Error parsing data.\n%@\n%@", [parseError localizedDescription], menuData);
    
    return [self parseWeek:weekData];
}

+ (Menu *)retrieveSavedMenus {
    Menu *savedMenu = [NSKeyedUnarchiver unarchiveObjectWithData:[ReadWriteLocalData readFile:kMenuLastSavedFilename]];
    
    if (!savedMenu || ![savedMenu isKindOfClass:[Menu class]])
        NSLog(@"savedMenu is nil or not kind of class Menu. %@ returns class of %@", savedMenu, [savedMenu class]);
    
    return savedMenu;
}

+ (void)retrieveMenusWithDelegate:(id<ParseMenuProtocol>)delegate {
    
    //Block for calling the delegate
    void (^alertDelegate)(Menu *, NSURLResponse *, NSError *) = ^void(Menu *outputMenu, NSURLResponse *menuResponse, NSError *menuError) {
        [delegate getMenuOnlineResultWithMenu:outputMenu withURLResponse:menuResponse withError:menuError];
    };
    
    //Block for saving menu to disk
    void (^saveMenu)(Menu *) = ^void(Menu *outputMenu) {
        NSData *menuData = [NSKeyedArchiver archivedDataWithRootObject:outputMenu];
        [ReadWriteLocalData saveData:menuData withFilename:kMenuLastSavedFilename];
    };
    
    Menu *outputMenu = [Menu new];
    
    if (kDebug) {
        for (int i = 1; i < 3; i++) {
            NSData *menuData = [self readSampleLocalNumber:i];
            [outputMenu addWeek:[self parseMenu:menuData]];
        }
        
        //NSData *outputMenuData = [NSKeyedArchiver archivedDataWithRootObject:outputMenu];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(20);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                saveMenu(outputMenu);
                alertDelegate(outputMenu, nil, nil);
            });
        });
    } else {
        /*
        NSURLComponents *components = [NSURLComponents componentsWithURL:[NSURL URLWithString: kServerURL] resolvingAgainstBaseURL:YES];
        components.scheme = kServerProtocol;
        components.path = kServerMenu1URL;
        
        
        
        NSString *noteDataString = [NSString stringWithFormat:@"key=%@", noteIdentifier];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *url = [NSURL URLWithString:kServerURL];
        url = [url URLByAppendingPathComponent:@"get"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPBody = [noteDataString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [_delegate getMeshNoteOnlineResultWithData:data withURLResponse:response withError:error];
        }];
        [postDataTask resume];
         */
    }
    
}

@end
