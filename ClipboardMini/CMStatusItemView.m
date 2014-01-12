//
//  CMStatusItemView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMStatusItemView.h"


#define VIEW_ICON_PADDING 3

@interface CMStatusItemView () {
    NSRect _circleIconRect;
}

@end

@implementation CMStatusItemView

#pragma mark - 
#pragma mark Mouse Events
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    [_delegate viewDidClicked:self];
}

#pragma mark - 
#pragma mark Lifecycle

- (id)init {
    CGFloat viewSide = [[NSStatusBar systemStatusBar] thickness];
    NSRect frame = NSMakeRect(0, 0, viewSide, viewSide);
    self = [super initWithFrame:frame];
    if (self) {
        _circleIconRect = NSInsetRect(frame, VIEW_ICON_PADDING, VIEW_ICON_PADDING);
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    [NSException raise:NSGenericException format:@"Use basic init instead"];
    return nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:_circleIconRect];
    [[NSColor blackColor] setStroke];
    [circlePath stroke];
}

@end
