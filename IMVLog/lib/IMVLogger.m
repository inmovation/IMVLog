//
//  IMVLog.m
//  IMVCommon
//
//  Created by 陈少华 on 15/6/19.
//  Copyright (c) 2015年 inmovation. All rights reserved.
//

#import "IMVLogger.h"

@interface IMVLogger ()

@property (strong, nonatomic) NSString *logHomePath;
@property (strong, nonatomic) NSMutableString *logMsgs;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSInteger cacheSize;
@property (nonatomic) NSInteger cacheNum;
@property (nonatomic) NSInteger lastDates;

@property (nonatomic) BOOL logFileEnable;

@property (nonatomic) dispatch_queue_t queue;

@end


@implementation IMVLogger

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)sharedInstence
{
    static id sharedInstence = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstence = [[self alloc] init];
    });
    return sharedInstence;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy_MM_dd";
        _logMsgs = [NSMutableString string];
        _queue = dispatch_queue_create("IMVLogToFileQueue", DISPATCH_QUEUE_SERIAL);
        _cacheSize = 100;
        _cacheNum = 0;
        _lastDates = 30;
        _logFileEnable = NO;
        _logHomePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"logs"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

#pragma mark private method
- (void)addMsg:(NSString *)msg
{
    if (!_logFileEnable) {
        return;
    }
    @synchronized(self) {
        [_logMsgs appendString:msg];
        _cacheNum++;
        if (_cacheNum>=_cacheSize) {
            [self synchronizeMsg];
        }
    }
}

- (void)synchronizeMsg
{
    if (!_logFileEnable) {
        return;
    }
    NSString *syncMsgs = [[NSString alloc] initWithString:_logMsgs];
    [_logMsgs setString:@""];
    _cacheNum = 0;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_logHomePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_logHomePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    dispatch_async(_queue, ^{
        NSString *path = [_logHomePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", [_dateFormatter stringFromDate:[NSDate date]]]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        if (fileHandle){
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[syncMsgs dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
        else{
            [syncMsgs writeToFile:path
                      atomically:NO
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
        }
    });
}

- (void)clearExpiredLogs
{
    NSDate *expireDate = [NSDate dateWithTimeInterval:-_lastDates*24*3600 sinceDate:[NSDate date]];
    NSString *expireFileName = [NSString stringWithFormat:@"%@.txt", [_dateFormatter stringFromDate:expireDate]];
    NSArray *subPathes = [[NSFileManager defaultManager] subpathsAtPath:_logHomePath];
    for (NSString *subpath in subPathes) {
        if ([subpath compare:expireFileName] == NSOrderedAscending) {
            [[NSFileManager defaultManager] removeItemAtPath:[_logHomePath stringByAppendingPathComponent:subpath] error:nil];
        }
    }
}

#pragma mark public method
+ (void)log:(IMVLogFlag)flg format:(NSString *)format, ...
{
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);

        NSString *caller = [[[[NSThread callStackSymbols] objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]] objectAtIndex:1];

        if (flg == IMVLogFlagDebug) {
            msg = [NSString stringWithFormat:@"[debug] [%@] %@\n\n", caller, msg];
        }
        else if (flg == IMVLogFlagError) {
            msg = [NSString stringWithFormat:@"[error] [%@] %@\n\n", caller, msg];
        }
        else if (flg == IMVLogFlagInfo) {
            msg = [NSString stringWithFormat:@"[info] [%@] %@\n\n", caller, msg];
        }
        else if (flg == IMVLogFlagWarn) {
            msg = [NSString stringWithFormat:@"[warm] [%@] %@\n\n", caller, msg];
        }
        
#ifdef DEBUG
        NSLog(@"%@", msg);
#endif
        
        [[IMVLogger sharedInstence] addMsg:[NSString stringWithFormat:@"[%@]%@", [NSDate date], msg]];
        
    }
    
}

- (void)setLogFileEnable:(BOOL)enable
{
    _logFileEnable = enable;
}

- (void)setLogFileHomePath:(NSString *)homePath
{
    _logHomePath = homePath;
    [[NSFileManager defaultManager] createDirectoryAtPath:_logHomePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)setLogCacheSize:(NSInteger)cacheSize;
{
    _cacheSize = cacheSize;
}

- (void)setLogFileLastTime:(NSInteger)date
{
    _lastDates = date;
}

- (void)clearLogFiles
{
    [[NSFileManager defaultManager] removeItemAtPath:_logHomePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:_logHomePath withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark - UIApplicationDelegate
- (void)applicationWillTerminate
{
    [self synchronizeMsg];
}

- (void)applicationDidEnterBackground
{
    [self synchronizeMsg];
    [self clearExpiredLogs];
}
@end
