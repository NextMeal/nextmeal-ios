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

@interface ParseMenu ()

@end

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

+ (Item *)parseItem:(NSObject *)itemData error:(NSError **)error {
    if (![itemData isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [NSString stringWithFormat:@"Parsed itemData is not of kind class NSDictionary.\n%@", itemData];
        if (*error)
            *error = [[NSError alloc] initWithDomain:kNMParseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
        return nil;
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

+ (Meal *)parseMeal:(NSObject *)mealData error:(NSError **)error {
    if (![mealData isKindOfClass:[NSArray class]]) {
        NSString *errorString = [NSString stringWithFormat:@"Parsed mealData is not of kind class NSArray.\n%@", mealData];
        if (*error)
            *error = [[NSError alloc] initWithDomain:kNMParseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
        return nil;

    }
    
    Meal *outputMeal = [Meal new];
    
    for (NSObject *itemData in (NSArray *)mealData) {
        Item *outputItem = [self parseItem:itemData error:error];
        if (outputItem)
            [outputMeal addItem:outputItem];
    }
    
    return outputMeal;
}

+ (Day *)parseDay:(NSObject *)dayData error:(NSError **)error {
    if (![dayData isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [NSString stringWithFormat:@"Parsed dayData is not of kind class NSDictionary.\n%@", dayData];
        if (*error)
            *error = [[NSError alloc] initWithDomain:kNMParseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
        return nil;
    }
    
    Day *outputDay = [Day new];
    
    NSArray<NSString *> *mealKeys = @[kBreakfastKey, kLunchKey, kDinnerKey];
    
    NSArray<NSObject *> *mealDatas = [((NSDictionary *)dayData) objectsForKeys:mealKeys notFoundMarker:[NSObject new]];
    
    for (NSObject *mealData in mealDatas) {
        [outputDay addMeal:[self parseMeal:mealData error:error]];
    }
    
    return outputDay;
}

+ (Week *)parseWeek:(NSObject *)weekData error:(NSError **)error {
    if (![weekData isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [NSString stringWithFormat:@"Parsed object is not of kind class NSDictionary.\n%@", weekData];
        if (*error)
            *error = [[NSError alloc] initWithDomain:kNMParseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
        return nil;
    }
    
    NSArray<NSString *> *dayKeys = @[kSundayKey, kMondayKey, kTuesdayKey, kWednesdayKey, kThursdayKey, kFridayKey, kSaturdayKey];
    
    NSArray<NSObject *> *dayDatas = [((NSDictionary *)weekData) objectsForKeys:dayKeys notFoundMarker:[NSObject new]];
    
    Week *outputWeek = [Week new];
    
    for (NSObject *dayData in dayDatas) {
        [outputWeek addDay:[self parseDay:dayData error:error]];
    }
    
    return outputWeek;
}

+ (Week *)parseMenu:(NSData *)menuData error:(NSError **)error {
    NSError *parseError;
    NSObject *weekData = [NSJSONSerialization JSONObjectWithData:menuData options:0 error:&parseError];
    
    if (parseError) {
        NSLog(@"Error parsing data.\n%@\n%@", [parseError localizedDescription], menuData);
        
        *error = parseError;
        return nil;
    }
    
    return [self parseWeek:weekData error:error];
}

+ (Menu *)retrieveSavedMenusWithError:(NSError **)error {
    Menu *savedMenu = [NSKeyedUnarchiver unarchiveObjectWithData:[ReadWriteLocalData readFile:kMenuLastSavedFilename]];
    
    if (!savedMenu || ![savedMenu isKindOfClass:[Menu class]]) {
        NSString *errorString = [NSString stringWithFormat:@"savedMenu is nil or not kind of class Menu.\n%@ returns class of %@", savedMenu, [savedMenu class]];
        if (*error)
            *error = [[NSError alloc] initWithDomain:kNMRetrieveSavedErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
    }
    
    return savedMenu;
}

+ (void)retrieveMenusWithDelegate:(id<ParseMenuProtocol>)delegate withOriginType:(NMRequestOriginType)originType {
    
    //Block for calling the delegate
    void (^alertDelegate)(Menu *, NSURLResponse *, NSError *) = ^void(Menu *outputMenu, NSURLResponse *menuResponse, NSError *menuError) {
        [delegate getMenuOnlineResultWithMenu:outputMenu withUpdateDate:[NSDate date] withURLResponse:menuResponse withError:menuError];
    };
    
    Menu *outputMenu = [Menu new];
    
    if (kDebug) { //set kDebug to YES to simulate network
        for (int i = 1; i < 3; i++) {
            NSData *menuData = [self readSampleLocalNumber:i];
            [outputMenu addWeek:[self parseMenu:menuData error:nil]];
        }
        
        //NSData *outputMenuData = [NSKeyedArchiver archivedDataWithRootObject:outputMenu];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(20);
            //saveMenu(outputMenu);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                alertDelegate(outputMenu, nil, nil);
            });
        });
    } else {
        NSArray<NSString *> *menuPaths = @[kServerMenu1Path, kServerMenu2Path];
        
        //Create large enough unloaded week array in the menu object.
        for (NSInteger i = 0; i < menuPaths.count; i++)
            [outputMenu addWeek:[Week new]];
        
        //Create array to keep track of requests completion
        NSLock *requestCompletionArrayLock = [NSLock new];
        NSMutableArray<NSNumber *> *requestComplete = [[NSMutableArray alloc] initWithCapacity:menuPaths.count];
        for (NSInteger i = 0; i < menuPaths.count; i++)
             [requestComplete addObject:[NSNumber numberWithBool:NO]];
        NSLock *requestErrorLock = [NSLock new];
        NSError * __block requestLastError;
        
        for (NSInteger i = 0; i < menuPaths.count; i++) {
            //Build request URL
            NSURLComponents *components = [NSURLComponents new];
            components.host = kServerHost;
            components.scheme = kServerProtocol;
            components.path = [menuPaths objectAtIndex:i];
            //NSLog(@"%@",components.string);
            
            //Determine appropriate origin type string to put in request data.
            NSString *originTypeString;
            switch (originType) {
                case NMForeground:
                    originTypeString = @"foreground";
                    break;
                case NMBackground:
                    originTypeString = @"backgroundFetch";
                    break;
                default:
                    originTypeString = [NSString stringWithFormat:@"%u",originType];
                    break;
            }
            
            //Build request data string.
            NSString *requestDataString = [NSString stringWithFormat:@"status=%@&appVersion=%@", originTypeString, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsP2PShareKey]) {
                NSInteger seedCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PSeedTotal];
                NSInteger leachCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PLeechTotal];
                requestDataString = [NSString stringWithFormat:@"%@&deviceId=%@&deviceName=%@&seedCount=%ld&leachCount=%ld", requestDataString, [UIDevice currentDevice].identifierForVendor, [UIDevice currentDevice].name, (long)seedCount, (long)leachCount];
            }
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            
            if (originType == NMBackground) {
                sessionConfiguration.timeoutIntervalForRequest = 10;
                sessionConfiguration.timeoutIntervalForResource = 25; //This is the important part for background fetch. Request for resource must end <30s. https://stackoverflow.com/a/31008311
            } else {
                sessionConfiguration.timeoutIntervalForRequest = kRequestTimeoutInteval;
                sessionConfiguration.timeoutIntervalForResource = kResourceTimeoutInterval;
            }
            
            
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
            NSURL *url = components.URL;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPBody = [requestDataString dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPMethod = @"POST";
            NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                //Lock/unlock the requestComplete counter array
                [requestCompletionArrayLock lock];
                [requestComplete replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                [requestCompletionArrayLock unlock];
                
                
                //If the request had no error, parse the data
                if (error) {
                    [requestErrorLock lock];
                    requestLastError = error; //update with any REQUEST error
                    [requestErrorLock unlock];
                } else {
                    Week *outputWeek = [self parseMenu:data error:&error];
                    
                    //Update menu object if parse has no error
                    if (error) {
                        [requestErrorLock lock];
                        requestLastError = error; //update with any PARSE error
                        [requestErrorLock unlock];
                    } else
                        [outputMenu updateWeekIndex:i withWeek:outputWeek];
                }
                
                //Call delegate if all requests have completed. Lock/unlock request complete array and loop to check if all values are YES.
                BOOL allRequestsComplete = YES;
                [requestCompletionArrayLock lock];
                for (NSNumber *value in requestComplete)
                    if (![value boolValue])
                        allRequestsComplete = NO;
                
                if (allRequestsComplete) {
                    //NSLog(@"all requests complete");
                    
                    /*
                    //If no errors, save the output menu
                    if (!requestLastError)
                        saveMenu(outputMenu);
                     */
                    if (requestLastError) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            alertDelegate(nil, response, requestLastError);
                        });
                    } else if (outputMenu.allWeeksValid) {
                        //Call delegate on main thread
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            alertDelegate(outputMenu, response, requestLastError);
                        });
                    } else {
                        NSString *errorString = @"Parsed outputMenu failed allWeeksValid check";
                        requestLastError = [[NSError alloc] initWithDomain:kNMParseErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey : errorString}];
                        
                        //Call delegate on main thread
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            alertDelegate(nil, response, requestLastError);
                        });
                    }
                }
                //Unlock requestCompletionArrayLock AFTER thread checks the allRequestComplete variable. Possible case of the first request thread to loop through requestComplete array but not check allRequestsComplete condition until the second thread loops through the requestComplete array and changes the allRequestsComplete variable. Then both threads will all delegate method > completionHandler may be called twice! (background fetch crash)
                [requestCompletionArrayLock unlock];
            }];
            [postDataTask resume];
        }
    }
    
}

@end
