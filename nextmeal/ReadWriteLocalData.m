//
//  ReadWriteLocalData.m
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "ReadWriteLocalData.h"

@implementation ReadWriteLocalData

+ (NSURL *)documentsPath {
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
     return [NSURL URLWithString:documentsDirectory];
}

+ (BOOL)doesFileExist:(NSString *)filename {
    if (!filename) {
        NSLog(@"no filename provided");
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[self documentsPath] path];
    NSString *filepath = [documentsPath stringByAppendingPathComponent:filename];
    
    return [fileManager fileExistsAtPath:filepath];
}

+ (NSData *)readFileFromBundle:(NSString *)filename {
    if (!filename) {
        NSLog(@"no filename provided");
        return nil;
    }
    
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];
    NSString *filepath = [documentsPath stringByAppendingPathComponent:filename];
    
    return [[NSData alloc] initWithContentsOfFile:filepath];
}

+ (NSData *)readFile:(NSString *)filename {
    if (!filename) {
        NSLog(@"no filename provided");
        return nil;
    }
    
    NSString *documentsPath = [[self documentsPath] path];
    NSString *filepath = [documentsPath stringByAppendingPathComponent:filename];
    
    return [[NSData alloc] initWithContentsOfFile:filepath];
}

+ (BOOL)saveData:(NSData *)data withFilename:(NSString *)filename {
    if (!filename) {
        NSLog(@"no filename provided");
        return NO;
    }
    
    NSString *documentsPath = [[self documentsPath] path];
    NSString *filepath = [documentsPath stringByAppendingPathComponent:filename];
    
    return [data writeToFile:filepath atomically:YES];
}

+ (BOOL)deleteFile:(NSString *)filename error:(NSError **)error{
    if (!filename) {
        NSLog(@"no filename provided");
        return NO;
    }
    
    NSString *documentsPath = [[self documentsPath] path];
    NSString *filepath = [documentsPath stringByAppendingPathComponent:filename];
    
    return [[NSFileManager defaultManager] removeItemAtPath:filepath error:error];
}

@end
