
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"
#import "BAAMR.h"

@interface BAAMR ()

@end

@implementation BAAMR

+ (BOOL)decAmr:(NSString *)amrFilePath toWav:(NSString *)wavFilePath {
    const char *amrCString = [amrFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    const char *wavCString = [wavFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    BOOL decoded = DecodeAMRFileToWAVEFile(amrCString, wavCString);
    
    return decoded;
}

+ (BOOL)encWav:(NSString *)wavFilePath toAmr:(NSString *)amrFilePath {
    const char *amrCString = [amrFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    const char *wavCString = [wavFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    BOOL encoded = EncodeWAVEFileToAMRFile(wavCString, amrCString, 1, 16);
    
    return encoded;
}

+ (BOOL)isAmr:(NSString *)filePath {
    return isAMRFile([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (BOOL)isMp3:(NSString *)filePath {
    return isMP3File([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
