//
//  CMClipboardChecker.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *CMClipboardNewItemNotification;

@interface CMChecker : NSObject

- (void)seedChecker;
- (void)stopChecker;

+ (instancetype)sharedClipboardChecker;
@end
