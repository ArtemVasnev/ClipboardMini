//
//  CMClipboardChecker.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMChecker.h"

static NSString * const CheckerUpdateInterval = @"CheckerUpdateInterval";
static NSString * const CMUpdateIntervalDidChangeNotification = @"CMUpdateIntervalDidChangeNotification";

NSString *CMClipboardNewItemNotification = @"ClipboardChecherNewItemNotification";



static CMChecker *_clipboardChecker;

@interface CMChecker () {
    
    NSTimer *_timer;
    NSArray *_pboardTypes;
    NSUInteger previousPboardChangeCount;
}
- (void)cmUpdateIntervalDidChange:(NSNotification *)notification;
- (void)checkPasteboard:(NSTimer *)timer;
@end

@implementation CMChecker

- (void)cmUpdateIntervalDidChange:(NSNotification *)notification {
    NSInteger updateInterval = [[notification.userInfo objectForKey:CheckerUpdateInterval] integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:updateInterval forKey:CheckerUpdateInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self seedChecker];
}
#pragma mark -
#pragma mark Timer Handling

- (void)checkPasteboard:(NSTimer *)timer {

        NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
        if (previousPboardChangeCount == [pBoard changeCount])
            return;
        
        for (NSPasteboardItem *item in [pBoard pasteboardItems]) {
            
            NSString *availableType = [item availableTypeFromArray:_pboardTypes];
            if (!availableType)
                continue;
            
            NSString *pasteboardString = [item stringForType:availableType];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CMClipboardNewItemNotification
                                                                object:nil
                                                              userInfo:@{availableType: pasteboardString}];
        }
    
        previousPboardChangeCount = [pBoard changeCount];
}

#pragma mark -
#pragma mark Public

- (void)seedChecker {
    
    if (_timer)
        [self stopChecker];
    NSInteger updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CheckerUpdateInterval];
    _timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                              target:self
                                            selector:@selector(checkPasteboard:)
                                            userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopChecker {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        _pboardTypes = @[(__bridge NSString *)kUTTypeFileURL, (__bridge NSString *)kUTTypeText];

        NSInteger updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CheckerUpdateInterval];
        if (!updateInterval) {
            [[NSUserDefaults standardUserDefaults] setInteger:1
                                                       forKey:CheckerUpdateInterval];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cmUpdateIntervalDidChange:)
                                                     name:CMUpdateIntervalDidChangeNotification
                                                   object:nil];
    }
    return self;
}

+ (instancetype)sharedClipboardChecker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _clipboardChecker = [[CMChecker alloc] init];
    });
    return _clipboardChecker;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
