//
//  CMMenuItemCell.m
//  ClipboardMini
//
//  Created by Artem on 03/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMFileMenuItemCell.h"
#import "NSImage+Helpers.h"
#import "NSURL+Helpers.h"

@implementation CMFileMenuItemCell

#pragma mark -
#pragma mark Property


#pragma mark -
#pragma mark Public


- (void)setFileUrl:(NSURL *)fileUrl {
    [titleLabel setStringValue:[fileUrl fileName]];
    [filePathLabel setStringValue:[[fileUrl path] stringByDeletingLastPathComponent]];
    iconView.image = nil;
    
    
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
                     inModes:[NSArray
                              arrayWithObject:NSEventTrackingRunLoopMode]];
}

#pragma mark -
#pragma mark Mouse Events

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    NSMenuItem *item = [self enclosingMenuItem];
    [NSApp sendAction:[item action] to:[item target] from:item];
}


#pragma mark -
#pragma mark Lifecycle




@end
