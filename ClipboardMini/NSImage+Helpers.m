//
//  NSImage+Helpers.m
//  ClipboardMini
//
//  Created by Artem on 03/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "NSImage+Helpers.h"

#define THUMB_SIDE 35

@implementation NSImage (Helpers)

+ (NSImage *)createThumbnailFromImageAtUrl:(NSURL *)imageUrl {
    
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    
    CGSize imageSize = [image size];
    CGFloat ratio = imageSize.width / imageSize.height;
    
    CGSize thumbSize = (ratio > 1) ? CGSizeMake(THUMB_SIDE, THUMB_SIDE / ratio) : CGSizeMake(THUMB_SIDE / ratio, THUMB_SIDE);
    
    NSImage *thumb = [[NSImage alloc] initWithSize:NSSizeFromCGSize(thumbSize)];
    [thumb lockFocus];
    [image drawInRect:NSMakeRect(0, 0, thumbSize.width, thumbSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [thumb unlockFocus];
    return thumb;
}

+ (NSImage *)getIconForFileAtUrl:(NSURL *)fileUrl {

    NSString *fileType = nil;
    [fileUrl getResourceValue:&fileType forKey:NSURLTypeIdentifierKey error:nil];
    BOOL isImage = UTTypeConformsTo((__bridge CFStringRef)fileType, kUTTypeImage);
    
    NSImage *icon = nil;
    if (isImage)
        icon = [NSImage createThumbnailFromImageAtUrl:fileUrl];
    else
        icon = [[NSWorkspace sharedWorkspace] iconForFile:[fileUrl path]];

    return icon;
}


@end

NSOperationQueue *IHQueue () {
    static NSOperationQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    return queue;
}


