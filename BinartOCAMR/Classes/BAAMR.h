//
//  VoiceConverterHeaders.h
//  TSWeChat
//
//  Created by Hilen on 1/5/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAAMR : NSObject

+ (BOOL)decAmr:(NSString *)amrFilePath toWav:(NSString *)wavFilePath;

+ (BOOL)encWav:(NSString *)wavFilePath toAmr:(NSString *)amrFilePath;

+ (BOOL)isAmr:(NSString *)filePath;

+ (BOOL)isMp3:(NSString *)filePath;

@end
