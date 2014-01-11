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

- (void)mouseEntered:(NSEvent *)theEvent {
    self.isHighlighted = YES;
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.isHighlighted = NO;
}

- (void)mouseUp:(NSEvent *)theEvent {
    self.isHighlighted = NO;
}

- (void)updateTrackingAreas {
    static NSTrackingArea *trackingArea;
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    NSTrackingAreaOptions trackingOptions = NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingEnabledDuringMouseDrag;
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                 options:trackingOptions
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}


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
