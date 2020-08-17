//
//  BAViewController.m
//  BinartOCAMR
//
//  Created by fallending on 08/17/2020.
//  Copyright (c) 2020 fallending. All rights reserved.
//

#import "BAViewController.h"
#import <BinartOCAMR/BAAMR.h>

const static NSString *kAudioFileTypeWav = @"wav";
const static NSString *kAudioFileTypeAmr = @"amr";
const static NSString *kAmrRecordFolder = @"ChatAudioAmrRecord";
const static NSString *kWavRecordFolder = @"ChatAudioWavRecord";


@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *amrPath = [[NSBundle mainBundle] pathForResource:@"hello" ofType:(NSString *)kAudioFileTypeAmr];
    NSString *wavPath = [[NSBundle mainBundle] pathForResource:@"count" ofType:(NSString *)kAudioFileTypeWav];
    
    NSString *amrTargetPath = [self amrPathWithName:@"test_amr"];
    NSString *wavTargetPath = [self wavPathWithName:@"test_wav"];
    
    if ([BAAMR decAmr:amrPath toWav:wavTargetPath]) {
        NSLog(@"wav path = %@", wavTargetPath);
    } else {
        NSLog(@"amr decoded failed");
    }
    
    if ([BAAMR encWav:wavPath toAmr:amrTargetPath]) {
        NSLog(@"amr path = %@", amrTargetPath);
    } else {
        NSLog(@"wav encoded failed");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: = Audio Directory Manager

- (NSString *)createAudioFolder:(const NSString *)folderName {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *folder = [documentDirectory stringByAppendingPathComponent:(NSString *)folderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:folder]) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return folder;
}

- (NSString *)amrFilesFolder {
    return [self createAudioFolder:kAmrRecordFolder];
}

- (NSString *)wavFilesFolder {
    return [self createAudioFolder:kWavRecordFolder];
}

- (NSString *)amrPathWithName:(NSString *)fileName {
    return [[self amrFilesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, kAudioFileTypeAmr]];
}

- (NSString *)wavPathWithName:(NSString *)fileName {
    return [[self amrFilesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, kAudioFileTypeWav]];
}

@end
