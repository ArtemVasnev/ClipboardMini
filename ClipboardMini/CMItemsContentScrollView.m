
//  CMItemsContentView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMItemsContentScrollView.h"
#import "NSLayoutConstraint+Helpers.h"

static NSString * const CMScrollViewVisibleRowNumber = @"VisibleRowNumber";
static NSString * const CMVisibleRowNumberDidChangeNotification = @"CMVisibleRowNumberDidChangeNotification";

@interface CMItemsContentScrollView () {
    NSMutableArray *contentSubViews;
    NSSize itemSize;
    NSSize contentSize;
    NSInteger visibleRowNumber;
}
- (void)cmVisibleRowNumberDidChange:(NSNotification *)notification;
- (void)removeAllSubviews;
- (void)layoutItemCells;
@end

@implementation CMItemsContentScrollView

- (void)cmVisibleRowNumberDidChange:(NSNotification *)notification {
    NSInteger newRowNumber = [[notification.userInfo objectForKey:CMScrollViewVisibleRowNumber] integerValue];
    
    if (visibleRowNumber != newRowNumber) {
        visibleRowNumber = newRowNumber;
        [[NSUserDefaults standardUserDefaults] setInteger:visibleRowNumber
                                                   forKey:CMScrollViewVisibleRowNumber];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reload];
    }
}

#pragma mark -
#pragma mark Mouse Events

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    CGPoint location = [theEvent locationInWindow];
    location = [self.documentView convertPoint:location fromView:nil];
    NSInteger selectedItem = location.y / itemSize.height;
    [_delegate didSelectItemAtRow:selectedItem];
}

#pragma mark -
#pragma mark Private

- (void)layoutItemCells {
    
    itemSize = [[contentSubViews firstObject] bounds].size;
    CGFloat totalHeight = itemSize.height * [contentSubViews count];
    CGFloat maxViewHeight = itemSize.height * visibleRowNumber;
    contentSize = CGSizeMake(itemSize.width, totalHeight);
    
    CGFloat yOffset;
    for (NSView *itemCell in contentSubViews) {
        itemCell.frame = NSMakeRect(0, yOffset, itemSize.width, itemSize.height);
        yOffset += itemSize.height;
    }
    
    NSSize newSize = CGSizeMake(itemSize.width, MIN(totalHeight, maxViewHeight));
    [_delegate didChangeContentSize:newSize];
    
    [self removeConstraint:heightConstraint];
    heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:newSize.height
                                                                 forItem:self];
    [self addConstraint:heightConstraint];
    [self layout];
}

- (void)removeAllSubviews {
    for (NSView *sView in contentSubViews)
        [sView removeFromSuperview];
    [contentSubViews removeAllObjects];
}

#pragma mark -
#pragma mark Public
- (void)reload {
    
    if (contentSubViews.count > 0)
        [self removeAllSubviews];
    
    NSInteger numberOfItems = [_dataSource numberOfItemsInContentView:self];
    
    for (NSInteger idx = 0; idx < numberOfItems; idx++) {
        NSView *itemCell = [_dataSource contentView:self itemCellForRow:idx];
        [self.documentView addSubview:itemCell];
        [contentSubViews addObject:itemCell];
    }
    
    // Scroll the contentView to top
    self.verticalScroller.floatValue = 0;
    [self.contentView scrollToPoint:NSMakePoint(0, 0)];
    
    BOOL allowScrolling = (numberOfItems > visibleRowNumber);
    self.hasVerticalScroller = allowScrolling;
    self.verticalScrollElasticity = (allowScrolling) ? NSScrollElasticityAllowed : NSScrollElasticityNone;
    
    [self layoutItemCells];
}

#pragma mark -
#pragma mark Lifecycle

- (void)layout {
    [super layout];
    [self.documentView setFrame:(CGRect) {.size = contentSize}];
}

- (void)awakeFromNib {
    contentSubViews = [@[] mutableCopy];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        visibleRowNumber = [df integerForKey:CMScrollViewVisibleRowNumber];
        if (!visibleRowNumber) {
            visibleRowNumber = 4;
            [df setInteger:4 forKey:CMScrollViewVisibleRowNumber];
            [df synchronize];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cmVisibleRowNumberDidChange:)
                                                     name:CMVisibleRowNumberDidChangeNotification
                                                   object:nil];
        
        heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:0
                                                                     forItem:self];
        [self addConstraint:heightConstraint];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
