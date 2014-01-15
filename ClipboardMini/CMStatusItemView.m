//
//  CMStatusItemView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMStatusItemView.h"
#import "CMChecker.h"


#define VIEW_ICON_PADDING 3

@interface CMStatusItemView () {
    NSRect _circleIconRect;
}

@property (nonatomic, assign) BOOL isNewPasteboardItem;
- (void)newPastrboardItem:(NSNotification *)notification;
@end

@implementation CMStatusItemView

- (void)newPastrboardItem:(NSNotification *)notification {
    if (!_isNewPasteboardItem && ![self.window isKeyWindow])
        self.isNewPasteboardItem = YES;
}

- (void)setIsNewPasteboardItem:(BOOL)isNewPasteboardItem {
    _isNewPasteboardItem = isNewPasteboardItem;
    [self setNeedsDisplay:YES];
}

#pragma mark - 
#pragma mark Mouse Events
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    self.isNewPasteboardItem = NO;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPastrboardItem:)
                                                     name:CMClipboardNewItemNotification
                                                   object:nil];
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
    
    if (_isNewPasteboardItem) {
        NSBezierPath *newItemCircle = [NSBezierPath bezierPathWithOvalInRect:CGRectInset(_circleIconRect, VIEW_ICON_PADDING, VIEW_ICON_PADDING)];
        [[NSColor redColor] setStroke];
        [newItemCircle stroke];
    }
}

@end
