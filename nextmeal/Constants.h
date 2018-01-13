//
//  Constants.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#ifndef Constants_h


#pragma mark - Debug constants

#define kDebug NO
#define kSampleFilename1 @"sampleMenu1.json"
#define kSampleFilename2 @"sampleMenu2.json"


#pragma mark - openURL parameters

#define kSelectedViewKey @"selectedView"
#define kSelectedViewNextMeal @"nextMeal"
#define kSelectedViewExtendedMenu @"extendedMenu"
#define kSelectedViewExtras @"extras"

#define kSelectedSectionKey @"selectedSection"


#pragma mark - NSNotification keys

#define kUnwindDetailView @"unwindDetailView"
#define kNotificationLoadView @"loadView"
#define kSelectedViewIndexKey @"selectedViewIndex"

#define kNotificationLoadSection @"loadSection"

#pragma mark - Settings bundle keys

#define kSettingsP2PKey @"p2p_preference"
#define kSettingsP2PShareKey @"p2p_stats_preference"


#pragma mark - Menu display configurable options

#define kNumberOfNextMealsShown 3
#define kMaxItemsShownNextMeal 5

#define kNumberOfNextMealsShownWidget 1
#define kMaxItemsShownNextMealWidget 3


#pragma mark - Saved keys and filenames

#define kMenuLastUpdatedKey @"menuLastUpdated"
#define kMenuLastSavedFilename @"menuLatest"

#define kP2PSeedTotal @"seedTotal"
#define kP2PLeechTotal @"leachTotal"

#define kLaunchesToReview 10
#define kLaunchesForVersionPrefix @"launchesFor"

#pragma mark - Connectivity constants

#define kServerProtocol @"https"
#define kServerHost @"navy.herokuapp.com"
#define kServerMenu1Path @"/menu"
#define kServerMenu2Path @"/menu2"
#define kAboutTextPath @"/about"

#define kRequestTimeoutInteval 60
#define kResourceTimeoutInterval 120

#define kNMParseErrorDomain @"NMParseErrorDomain"
#define kNMRetrieveSavedErrorDomain @"NMRetrieveSavedErrorDomain"

#pragma mark - P2P constants

#define kNMServiceType @"NMMultipeerMenu"
#define kNMDiscoveryInfoMenuUpdateDate @"menuUpdateDate"

#define kNMOutOfDateTimeInterval -10

#define kNMMultipeerDeviceIdBlacklistKey @"multipeerDeviceIdBlacklistKey"

#define kP2PLeaderboardURL @"nextmeal.github.io/leaderboard"


#pragma mark - Menu JSON key constants

#define kSundayKey @"U"
#define kMondayKey @"M"
#define kTuesdayKey @"T"
#define kWednesdayKey @"W"
#define kThursdayKey @"R"
#define kFridayKey @"F"
#define kSaturdayKey @"S"

#define kBreakfastKey @"B"
#define kLunchKey @"L"
#define kDinnerKey @"D"

#define kMealItemTitleKey @"title"

#define kMorningMealTitle @"Breakfast"
#define kNoonMealTitle @"Lunch"
#define kEveningMealTitle @"Dinner"


#pragma mark - Watchkit key constants

#define kNextMealKey @"nextMeal"
#define kCachedMealKey @"cachedMeal"
#define kItemTitleKey @"itemTitle"

#pragma mark - Type definitions

typedef enum {
    NMForeground,
    NMBackground
} NMRequestOriginType;

#define Constants_h


#endif /* Constants_h */
