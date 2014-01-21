//
//  CMClipboardChecker.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMChecker.h"

static NSString * const CMCheckerUpdateInterval = @"CheckerUpdateInterval";
static NSString * const CMUpdateIntervalDidChangeNotification = @"CMUpdateIntervalDidChangeNotification";

NSString *CMClipboardNewItemNotification = @"ClipboardChecherNewItemNotification";

static CMChecker *ClipboardChecker;

@interface CMChecker () {
    NSTimer *timer;
    NSArray *pboardTypes;
    NSUInteger previousPboardChangeCount;
}
- (void)cmUpdateIntervalDidChange:(NSNotification *)notification;
- (void)checkPasteboard:(NSTimer *)timer;
@end

@implementation CMChecker

- (void)cmUpdateIntervalDidChange:(NSNotification *)notification {
    NSInteger updateInterval = [[notification.userInfo objectForKey:CMCheckerUpdateInterval] integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:updateInterval forKey:CMCheckerUpdateInterval];
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
            
            NSString *availableType = [item availableTypeFromArray:pboardTypes];
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
    
    if (timer)
        [self stopChecker];
    
    NSInteger updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CMCheckerUpdateInterval];
    timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                              target:self
                                            selector:@selector(checkPasteboard:)
                                            userInfo:nil repeats:YES];
    [timer fire];
}

- (void)stopChecker {
    [timer invalidate];
    timer = nil;
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        pboardTypes = @[(__bridge NSString *)kUTTypeFileURL, (__bridge NSString *)kUTTypeText];

        NSInteger updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CMCheckerUpdateInterval];
        if (!updateInterval) {
            [[NSUserDefaults standardUserDefaults] setInteger:1
                                                       forKey:CMCheckerUpdateInterval];
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
        ClipboardChecker = [[CMChecker alloc] init];
    });
    return ClipboardChecker;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
