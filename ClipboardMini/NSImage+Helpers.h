//
//  NSImage+Helpers.h
//  ClipboardMini
//
//  Created by Artem on 03/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (Helpers)

+ (NSImage *)createThumbnailFromImageAtUrl:(NSURL *)imageUrl;
+ (NSImage *)getIconForFileAtUrl:(NSURL *)fileUrl;

@end

NSOperationQueue *IHQueue ();