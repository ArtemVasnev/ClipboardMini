//
//  CMMenuItemCell.m
//  ClipboardMini
//
//  Created by Artem on 03/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMFileItemCell.h"
#import "NSImage+Helpers.h"
#import "NSURL+Helpers.h"

@interface CMFileItemCell ()
- (void)loadIconForFileAtUrl:(NSURL *)fileUrl;
@end

@implementation CMFileItemCell

#pragma mark - 
#pragma mark Private

- (void)loadIconForFileAtUrl:(NSURL *)fileUrl {
    [IHQueue() addOperationWithBlock:^{
        NSImage *icon = [NSImage getIconForFileAtUrl:fileUrl];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            iconView.image = icon;
            [spinner stopAnimation:nil];
            [spinner setHidden:YES];
        }];
    }];
    
    [spinner setHidden:NO];
    [spinner performSelector:@selector(startAnimation:)
                  withObject:self
                  afterDelay:0.0
                     inModes:@[NSEventTrackingRunLoopMode]];
}

#pragma mark -
#pragma mark Public

- (void)setFileUrl:(NSURL *)fileUrl icon:(NSImage *)icon {
    [titleLabel setStringValue:[fileUrl fileName]];
    [filePathLabel setStringValue:[[fileUrl path] stringByDeletingLastPathComponent]];
    iconView.image = icon;
    
    if (!iconView.image)
        [self loadIconForFileAtUrl:fileUrl];
}


#pragma mark -
#pragma mark Lifecycle

@end
