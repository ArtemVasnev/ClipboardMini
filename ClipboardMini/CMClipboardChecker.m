//
//  CMClipboardChecker.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMClipboardChecker.h"

static CMClipboardChecker *_clipboardChecker;

@interface CMClipboardChecker () {
    NSTimer *_timer;
    NSArray *_pboardTypes;
    NSUInteger previousPboardCount;
}
- (void)checkPasteboard:(NSTimer *)timer;
@end

@implementation CMClipboardChecker

#pragma mark - Private

- (void)checkPasteboard:(NSTimer *)timer {
    NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
    if (previousPboardCount == [pBoard changeCount]) {
        return;
    }
    
    
    for (NSPasteboardItem *item in [pBoard pasteboardItems]) {
        
        NSString *availableType = [item availableTypeFromArray:_pboardTypes];
        if (!availableType)
            continue;
        
        NSString *pasteboardString = [item stringForType:availableType];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ClipboardChecherNewPasteboardItemNotification
                                                            object:nil
                                                          userInfo:@{availableType: pasteboardString}];
    }
    
    previousPboardCount = [pBoard changeCount];
}

#pragma mark -
#pragma mark Public
- (void)seedChecker {
    _timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(checkPasteboard:)
                                   userInfo:nil repeats:YES];
    [_timer fire];
    
    //    NSString *mode = isTracking ? NSEventTrackingRunLoopMode : NSRunLoopCommonModes;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopChecker {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _pboardTypes = @[(__bridge NSString *)kUTTypeFileURL, (__bridge NSString *)kUTTypeText];
    }
    return self;
}

+ (instancetype)sharedClipboardChecker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _clipboardChecker = [[CMClipboardChecker alloc] init];
    });
    return _clipboardChecker;
}

@end
