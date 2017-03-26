//
//  ReadWriteLocalData.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadWriteLocalData : NSObject

+ (BOOL)doesFileExist:(NSString *)filename;
+ (NSData *)readFileFromBundle:(NSString *)filename;
+ (NSData *)readFile:(NSString *)filename;
+ (BOOL)saveData:(NSData *)data withFilename:(NSString *)filename;
+ (BOOL)deleteFile:(NSString *)filename error:(NSError **)error;

@end
