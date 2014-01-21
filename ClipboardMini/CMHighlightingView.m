//
//  CMHighlightingView.m
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMHighlightingView.h"

@implementation CMHighlightingView

- (void)setIsHighlighted:(BOOL)isHighlighted {
    _isHighlighted = isHighlighted;
    [self setNeedsDisplay:YES];
}

#pragma mark - 
#pragma mark Mouse Events
- (void)mouseEntered:(NSEvent *)theEvent {
    self.isHighlighted = YES;
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.isHighlighted = NO;
}

- (void)updateTrackingAreas {
    if ([self.trackingAreas count] == 0)
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
}


#pragma mark - 
#pragma mark Lifecycle
- (void)drawRect:(NSRect)dirtyRect
{
    if (_isHighlighted) {
        [[NSColor alternateSelectedControlColor] set];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    } else {
        [[NSColor clearColor] set];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
}

@end
