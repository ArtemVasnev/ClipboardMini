
//  CMItemsContentView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMItemsContentView.h"



@interface CMItemsContentView () {
    CGFloat itemHeight;
}
- (void)layoutItemCells;
- (void)removeAllSubviews;
@end

@implementation CMItemsContentView

#pragma mark -
#pragma mark Mouse Events

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    CGPoint location = [theEvent locationInWindow];
    location = [self convertPoint:location fromView:nil];

    NSInteger selectedItem = location.y / itemHeight;
    [_delegate didSelectItemAtRow:selectedItem];
}

#pragma mark -
#pragma mark Private

- (void)layoutItemCells {
    
    CGSize viewSize = [[self.subviews firstObject] bounds].size;
    itemHeight = viewSize.height;
    NSPoint origin = NSZeroPoint;
    
    for (NSView *itemCell in self.subviews) {
        itemCell.frame = NSMakeRect(origin.x, origin.y, viewSize.width, viewSize.height);
        origin.y += viewSize.height;
    }
    
    CGSize contentSize = CGSizeMake(viewSize.width, viewSize.height * [self.subviews count]);
    
    [_delegate didChangeContentSize:contentSize];
}

- (void)removeAllSubviews {
    NSArray *subviews = [NSArray arrayWithArray:self.subviews];
    for (NSView *sView in subviews)
        [sView removeFromSuperview];
    
}
#pragma mark -
#pragma mark Public

- (void)clear {
    [self removeAllSubviews];
    [_delegate didChangeContentSize:CGSizeMake(CGRectGetWidth(self.bounds), 0)];
}

- (void)reload {
    
    if (self.subviews.count > 0) 
            [self removeAllSubviews];
    
    NSInteger numberOfItems = [_dataSource numberOfItemsInContentView:self];
    
    if (numberOfItems == 0)
        return;
    
    for (NSInteger idx = 0; idx < numberOfItems; idx++) {
        NSView *itemCell = [_dataSource contentView:self itemCellForRow:idx];
        [self addSubview:itemCell];
    } 
    
    [self layoutItemCells];
}


#pragma mark -
#pragma mark Lifecycle
- (BOOL)isFlipped {
    return YES;
}



@end
