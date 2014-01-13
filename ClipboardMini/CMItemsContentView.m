
//  CMItemsContentView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMItemsContentView.h"

#define MAX_ITEMS 4

@interface CMItemsContentView () {
    NSMutableArray *_cbItems;
    NSSize _itemSize;
    NSSize _maxContentViewSize;
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
    location = [contentScrollView.documentView convertPoint:location fromView:nil];
    NSInteger selectedItem = location.y / _itemSize.height;
    [_delegate didSelectItemAtRow:selectedItem];
}

#pragma mark -
#pragma mark Private

- (void)layoutItemCells {
    
    _itemSize = [[_cbItems firstObject] bounds].size;
    CGFloat totalHeight = _itemSize.height * [_cbItems count];
    CGFloat maxViewHeight = _itemSize.height * MAX_ITEMS;
    
    CGPoint origin = CGPointZero;
    
    for (NSView *itemCell in _cbItems) {
        itemCell.frame = NSMakeRect(origin.x, origin.y, _itemSize.width, _itemSize.height);
        origin.y += _itemSize.height;
    }
    
    CGFloat newHeight = (totalHeight < maxViewHeight) ? totalHeight : maxViewHeight;
    [_delegate didChangeContentSize:CGSizeMake(_itemSize.width, newHeight)];
    [self layout];
}

- (void)removeAllSubviews {
    
    for (NSView *cbView in _cbItems)
        [cbView removeFromSuperview];
    
    [_cbItems removeAllObjects];
}


#pragma mark -
#pragma mark Public

- (void)clear {
    [self removeAllSubviews];
    [_delegate didChangeContentSize:CGSizeMake(CGRectGetWidth(self.bounds), 0)];
    
}

- (void)reload {
    
    if (_cbItems.count > 0)
        [self removeAllSubviews];
    
    NSInteger numberOfItems = [_dataSource numberOfItemsInContentView:self];
    
    for (NSInteger idx = 0; idx < numberOfItems; idx++) {
        NSView *itemCell = [_dataSource contentView:self itemCellForRow:idx];
        [contentScrollView.documentView addSubview:itemCell];
        [_cbItems addObject:itemCell];
    }
    
    // Scroll the contentView to top
    contentScrollView.verticalScroller.floatValue = 0;
    [contentScrollView.contentView scrollToPoint:NSMakePoint(0, 0)];
    
    BOOL allowScrolling = (numberOfItems > MAX_ITEMS);
    contentScrollView.hasVerticalScroller = allowScrolling;
    contentScrollView.verticalScrollElasticity = (allowScrolling) ? NSScrollElasticityAllowed : NSScrollElasticityNone;
    
    [self layoutItemCells];
}

#pragma mark -
#pragma mark Lifecycle

- (void)layout {
    [super layout];
    contentScrollView.frame = self.bounds;
    
    NSRect frame = [contentScrollView.documentView frame];
    frame.size = NSMakeSize(_itemSize.width,  _itemSize.height * [_cbItems count]);
    [contentScrollView.documentView setFrame:frame];
}

- (void)awakeFromNib {
    _cbItems = [@[] mutableCopy];
}


@end
