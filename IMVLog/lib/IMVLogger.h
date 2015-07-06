//
//  IMVLog.h
//  IMVCommon
//
//  Created by 陈少华 on 15/6/19.
//  Copyright (c) 2015年 inmovation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


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
#ifndef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF imvLogLevel
#endif

#ifdef DEBUG
static const IMVLogLevel imvLogLevel = IMVLogLevelDebug;
#else
static const IMVLogLevel imvLogLevel = IMVLogLevelOff;
#endif

#define IMV_LOG_MACRO(flg, frmt, ...)                  \
        [IMVLogger log : flg                           \
                format : (frmt), ## __VA_ARGS__]

#define NSLogError(frmt, ...)    IMV_LOG_MACRO(IMVLogFlagError, frmt, ## __VA_ARGS__);
#define NSLogWarn(frmt, ...)     do{ if(LOG_LEVEL_DEF & IMVLogFlagWarn) IMV_LOG_MACRO(IMVLogFlagWarn, frmt, ## __VA_ARGS__); } while(0)
#define NSLogInfo(frmt, ...)    do{ if(LOG_LEVEL_DEF & IMVLogFlagInfo) IMV_LOG_MACRO(IMVLogFlagInfo, frmt, ## __VA_ARGS__); } while(0)
#define NSLogDebug(frmt, ...)  do{ if(LOG_LEVEL_DEF & IMVLogFlagDebug) IMV_LOG_MACRO(IMVLogFlagDebug, frmt, ## __VA_ARGS__); } while(0)

/**
 *  this is a simple log framework for ios refered to CocoaLumberjack, a powerful log framework
 *  support diffrent log level, persistent log to file
 */
@interface IMVLogger : UIControl

+ (instancetype)sharedInstence;

/**
 *  used by IMV_LOG_MACRO
 *
 *  @param flg    flag
 *  @param format format
 */
+ (void)log:(IMVLogFlag)flg format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 *  whether persitent log to file
 *  file named: yyyy_MM_dd.txt
 *  @param enable default: false
 */
- (void)setLogFileEnable:(BOOL)enable;

/**
 *  set home path of log files
 *
 *  @param homePath default: {sandboxpath}/logs/
 */
- (void)setLogFileHomePath:(NSString *)homePath;

/**
 *  set the maxCacheSize of log
 *  when log a message, message will cached in memory, if the count of cached messages > maxCacheSize, the cached message will persistent to file
 *
 *  @param cacheSize default: 1000
 */
- (void)setLogCacheSize:(NSInteger)cacheSize;

/**
 *  set the last date of log file
 *  the log file will be cleard
 *
 *  @param size default 30
 */
- (void)setLogFileLastTime:(NSInteger)date;

/**
 *  clear all log files
 */
- (void)clearLogFiles;

@end
