//
//  CMClipboardItem.m
//  ClipboardMini
//
//  Created by Artem on 10/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMClipboardItem.h"

@implementation CMClipboardItem

- (BOOL)isFileItem {
    return ([self isKindOfClass:[CMClipboardFileItem class]]) ? YES : NO;
}

+ (instancetype)clipboardItemWithUrl:(NSURL *)url {
    return [CMClipboardFileItem clipboardFileItem:url];
}

+ (instancetype)clipboardItemWithText:(NSString *)cText {
    return [CMClipboardTextItem clipboardTextItem:cText];
}

@end


@implementation CMClipboardFileItem

- (id)initWithFileUrl:(NSURL *)fileUrl {
    if (self = [super init])
        _fileUrl = fileUrl;
    return self;
}

+ (instancetype)clipboardFileItem:(NSURL *)fileUrl {
    return [[CMClipboardFileItem alloc] initWithFileUrl:fileUrl];
}

@end

@implementation CMClipboardTextItem

- (id)initWithClipboardText:(NSString *)cText {
    if (self = [super init])
        _clipboardText = [cText copy];
    return self;
}

+ (instancetype)clipboardTextItem:(NSString *)cText {
    return [[CMClipboardTextItem alloc] initWithClipboardText:cText];
}

@end