//
//  RoundRectView.m
//  ClipboardMini
//
//  Created by Artem on 10/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "RoundRectView.h"
@interface RoundRectView () {
    NSUInteger _cornerRadius;
}
@end

@implementation RoundRectView

#pragma mark -
#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frameRect cornerRadius:(NSInteger)cRadius {
    self = [super initWithFrame:frameRect];
    if (self)
        _cornerRadius = cRadius;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}




- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *roundRect = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:_cornerRadius yRadius:_cornerRadius];
    [[NSColor windowBackgroundColor] setFill];
    [roundRect fill];
}

@end
