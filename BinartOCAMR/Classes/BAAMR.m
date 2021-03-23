
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"
#import "BAAMR.h"

static const int amrPacketSizeArray[] = { 12, 13, 15, 17, 19, 20, 26, 31, 5, 6, 5, 5, 0, 0, 0, 0 };

@interface BAAMR ()

@end

@implementation BAAMR

+ (BOOL)decAmr:(NSString *)amrFilePath toWavUndetermined:(NSString *)wavFilePath {
    NSData *data = [BAAMR decodeAsWaveWithAMRFilePath:amrFilePath sampleRate:8000 bitsPerSample:16 channels:1];
    BOOL written = [data writeToFile:wavFilePath atomically:YES];
    return  written;
}

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


+(NSData *)decodeAsWaveWithAMRFilePath:(NSString *)amrFilePath
                            sampleRate:(int)sampleRate
                         bitsPerSample:(int)bitsPerSample
                              channels:(int)channels {


    FILE *amrFile = fopen(amrFilePath.UTF8String, "r");
    if (!amrFile) {
        return nil;
    }

    char header[6];

    size_t n = fread(header, 1, 6, amrFile);
    if (n != 6 || memcmp(header, "#!AMR\n", 6)) {
        fclose(amrFile);

        NSLog(@"Bad AMR header!");
        return nil;
    }


    NSMutableData *data = [[NSMutableData alloc] initWithLength:44];

    void *amr = Decoder_Interface_init();

    // bitsPerSample=16, i.e. 2 bytes per sample
    const int frameSize = 320;
    const int sampleCount = frameSize / 2;
    int16_t sampleBuf[sampleCount];
    uint8_t encodedBuf[500];

    int length = 0;
    BOOL isLittleEndian = [self isLittleEndian];

    while (1) {
        size_t n = fread(encodedBuf, 1, 1, amrFile);
        if (n <= 0) {
            break;
        }

        size_t packetSize = amrPacketSizeArray[(encodedBuf[0] >> 3) & 0x0f];
        n = fread(encodedBuf + 1, 1, packetSize, amrFile);
        if (n != packetSize) {
            break;
        }

        // decode the packet
        Decoder_Interface_Decode(amr, encodedBuf, sampleBuf, 0);

        // if it is big endian, swap the bytes
        if (!isLittleEndian) {
            for (int i = 0; i < sampleCount; ++i) {
                uint16_t n = sampleBuf[i];
                sampleBuf[i] = ((n << 8) & 0xff00) | (n >> 8);
            }
        }

        [data appendBytes:(int8_t *)sampleBuf length:frameSize];

        length += frameSize;
    }

    fclose(amrFile);
    Decoder_Interface_exit(amr);

    fseek(amrFile, 0, SEEK_SET);
    [self writeWaveHeaderToBuffer:(uint8_t *)data.bytes withAudioDataLength:length sampleRate:sampleRate bitsPerSample:bitsPerSample channels:channels];

    return data;
}

+(void)writeWaveHeaderToBuffer:(uint8_t *)buffer
           withAudioDataLength:(int)length
                    sampleRate:(int)sampleRate
                 bitsPerSample:(int)bitsPerSample
                      channels:(int) channels {

    int offset = 0;
    [self writeData:(uint8_t *)"RIFF" len:4 toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeLittleEndianUint32:4 + 8 + 16 + 8 + length toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeData:(uint8_t *)"WAVE" len:4 toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeData:(uint8_t *)"fmt " len:4 toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeLittleEndianUint32:16 toBuffer:buffer atOffset:offset];
    offset += 4;

    int bytesPerFrame = bitsPerSample / 8 * channels;
    int bytesPerSecond = bytesPerFrame * sampleRate;

    [self writeLittleEndianUint16:1 toBuffer:buffer atOffset:offset];
    offset += 2;
    [self writeLittleEndianUint16:channels toBuffer:buffer atOffset:offset];
    offset += 2;
    [self writeLittleEndianUint32:sampleRate toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeLittleEndianUint32:bytesPerSecond toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeLittleEndianUint16:bytesPerFrame toBuffer:buffer atOffset:offset];
    offset += 2;
    [self writeLittleEndianUint16:bitsPerSample toBuffer:buffer atOffset:offset];
    offset += 2;

    [self writeData:(uint8_t *)"data" len:4 toBuffer:buffer atOffset:offset];
    offset += 4;
    [self writeLittleEndianUint32:length toBuffer:buffer atOffset:offset];
}

+(void)writeData:(uint8_t *)data len:(int)len toBuffer:(uint8_t *)buffer atOffset:(int)offset {
    memcpy(buffer + offset, data, len);
}

+(void)writeLittleEndianUint16:(uint16_t)num toBuffer:(uint8_t *)buffer atOffset:(int)offset {
    buffer[offset + 0] = (uint8_t)(num >> 0);
    buffer[offset + 1] = (uint8_t)(num >> 8);
}

+(void)writeLittleEndianUint32:(uint32_t)num toBuffer:(uint8_t *)buffer atOffset:(int)offset {
    buffer[offset + 0] = (uint8_t)(num >> 0);
    buffer[offset + 1] = (uint8_t)(num >> 8);
    buffer[offset + 2] = (uint8_t)(num >> 16);
    buffer[offset + 3] = (uint8_t)(num >> 24);
}


+(BOOL)isLittleEndian {
    uint16_t n = 0x0102;
    return *((uint8_t *)&n) == 2;
}

@end
