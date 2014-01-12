//
//  CMClipboardItem.h
//  ClipboardMini
//
//  Created by Artem on 10/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMClipboardItem : NSObject
@property (nonatomic, readonly) BOOL isFileItem;

+ (instancetype)clipboardItemWithUrl:(NSURL *)url;
+ (instancetype)clipboardItemWithText:(NSString *)cText;
@end


#pragma mark - File Item
@interface CMClipboardFileItem : CMClipboardItem
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSString *fileName;

- (id)initWithFileUrl:(NSURL *)fileUrl;
+ (instancetype)clipboardFileItem:(NSURL *)fileUrl;
@end

#pragma mark - Text Item
@interface CMClipboardTextItem : CMClipboardItem
@property (nonatomic, readonly) NSString *clipboardText;
@property (nonatomic, readonly) NSString *trimmedClipboardText;

- (id)initWithClipboardText:(NSString *)cText;
+ (instancetype)clipboardTextItem:(NSString *)cText;
@end