//
//  IMVLog.h
//  IMVCommon
//
//  Created by 陈少华 on 15/6/19.
//  Copyright (c) 2015年 inmovation. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_OPTIONS(NSUInteger, IMVLogFlag) {
    IMVLogFlagError      = (1 << 0), // 0...00001
    IMVLogFlagWarn       = (1 << 1), // 0...00010
    IMVLogFlagInfo       = (1 << 2), // 0...00100
    IMVLogFlagDebug      = (1 << 3), // 0...01000
};

typedef NS_ENUM(NSUInteger, IMVLogLevel) {
    IMVLogLevelOff       = 0,
    IMVLogLevelError     = (IMVLogFlagError),                       // 0...00001
    IMVLogLevelWarn      = (IMVLogLevelError   | IMVLogFlagWarn), // 0...00011
    IMVLogLevelInfo      = (IMVLogLevelWarn | IMVLogFlagInfo),    // 0...00111
    IMVLogLevelDebug     = (IMVLogLevelInfo    | IMVLogFlagDebug),   // 0...01111
    IMVLogLevelAll       = NSUIntegerMax                           // 1111....11111
};

#ifdef DEBUG
static const int imvLogLevel = IMVLogLevelDebug;
#else
static const int imvLogLevel = IMVLogLevelOff;
#endif

#define IMV_LOG_MACRO(flg, frmt, ...) \
[IMVLogger log : flg                                \
format : (frmt), ## __VA_ARGS__]

#define NSLogError(frmt, ...)    IMV_LOG_MACRO(IMVLogFlagError, frmt, ## __VA_ARGS__);
#define NSLogWarn(frmt, ...)     do{ if(imvLogLevel & IMVLogFlagWarn) IMV_LOG_MACRO(IMVLogFlagWarn, frmt, ## __VA_ARGS__); } while(0)
#define NSLogInfo(frmt, ...)    do{ if(imvLogLevel & IMVLogFlagInfo) IMV_LOG_MACRO(IMVLogFlagInfo, frmt, ## __VA_ARGS__); } while(0)
#define NSLogDebug(frmt, ...)  do{ if(imvLogLevel & IMVLogFlagDebug) IMV_LOG_MACRO(IMVLogFlagDebug, frmt, ## __VA_ARGS__); } while(0)


@interface IMVLogger : UIControl

+ (instancetype)sharedInstence;

+ (void)log:(IMVLogFlag)flg format:(NSString *)format, ...;

- (void)setLogToFileEnable:(BOOL)enable;

- (void)setLogToFileHomePath:(NSString *)homePath;

- (void)setLogCacheSize:(NSInteger)size;

@end
