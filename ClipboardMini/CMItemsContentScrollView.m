
//  CMItemsContentView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMItemsContentScrollView.h"
#import "NSLayoutConstraint+Helpers.h"

static NSString * const ScrollViewVisibleRowNumber = @"VisibleRowNumber";
static NSString * const CMVisibleRowNumberDidChangeNotification = @"CMVisibleRowNumberDidChangeNotification";

@interface CMItemsContentScrollView () {
    NSMutableArray *_sViews;
    NSSize _itemSize;
    NSSize _contentSize;
    NSInteger _visibleRowNumber;
}
- (void)cmVisibleRowNumberDidChange:(NSNotification *)notification;
- (void)removeAllSubviews;
- (void)layoutItemCells;
@end

@implementation CMItemsContentScrollView

- (void)cmVisibleRowNumberDidChange:(NSNotification *)notification {
    NSInteger newRowNumber = [[notification.userInfo objectForKey:ScrollViewVisibleRowNumber] integerValue];
    
    if (_visibleRowNumber != newRowNumber) {
        _visibleRowNumber = newRowNumber;
        [[NSUserDefaults standardUserDefaults] setInteger:_visibleRowNumber
                                                   forKey:ScrollViewVisibleRowNumber];
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
    NSInteger selectedItem = location.y / _itemSize.height;
    [_delegate didSelectItemAtRow:selectedItem];
}

#pragma mark -
#pragma mark Private

- (void)layoutItemCells {
    
    _itemSize = [[_sViews firstObject] bounds].size;
    CGFloat totalHeight = _itemSize.height * [_sViews count];
    CGFloat maxViewHeight = _itemSize.height * _visibleRowNumber;
    _contentSize = CGSizeMake(_itemSize.width, totalHeight);
    
    CGFloat yOffset;
    for (NSView *itemCell in _sViews) {
        itemCell.frame = NSMakeRect(0, yOffset, _itemSize.width, _itemSize.height);
        yOffset += _itemSize.height;
    }
    
    NSSize newSize = CGSizeMake(_itemSize.width, MIN(totalHeight, maxViewHeight));
    [_delegate didChangeContentSize:newSize];
    
    [self removeConstraint:_heightConstraint];
    _heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:newSize.height
                                                                 forItem:self];
    [self addConstraint:_heightConstraint];
    [self layout];
}

- (void)removeAllSubviews {
    for (NSView *sView in _sViews)
        [sView removeFromSuperview];
    [_sViews removeAllObjects];
}

#pragma mark -
#pragma mark Public
- (void)reload {
    
    if (_sViews.count > 0)
        [self removeAllSubviews];
    
    NSInteger numberOfItems = [_dataSource numberOfItemsInContentView:self];
    
    for (NSInteger idx = 0; idx < numberOfItems; idx++) {
        NSView *itemCell = [_dataSource contentView:self itemCellForRow:idx];
        [self.documentView addSubview:itemCell];
        [_sViews addObject:itemCell];
    }
    
    // Scroll the contentView to top
    self.verticalScroller.floatValue = 0;
    [self.contentView scrollToPoint:NSMakePoint(0, 0)];
    
    BOOL allowScrolling = (numberOfItems > _visibleRowNumber);
    self.hasVerticalScroller = allowScrolling;
    self.verticalScrollElasticity = (allowScrolling) ? NSScrollElasticityAllowed : NSScrollElasticityNone;
    
    [self layoutItemCells];
}

#pragma mark -
#pragma mark Lifecycle

- (void)layout {
    [super layout];
    [self.documentView setFrame:(CGRect) {.size = _contentSize}];
}

- (void)awakeFromNib {
    _sViews = [@[] mutableCopy];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        _visibleRowNumber = [df integerForKey:ScrollViewVisibleRowNumber];
        if (!_visibleRowNumber) {
            _visibleRowNumber = 4;
            [df setInteger:4 forKey:ScrollViewVisibleRowNumber];
            [df synchronize];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cmVisibleRowNumberDidChange:)
                                                     name:CMVisibleRowNumberDidChangeNotification
                                                   object:nil];
        
        _heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:0
                                                                     forItem:self];
        [self addConstraint:_heightConstraint];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
