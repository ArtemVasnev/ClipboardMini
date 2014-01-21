//
//  CMStatusItemView.m
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMStatusItemView.h"
#import "CMChecker.h"

static CGFloat const CMNewItemIconPadding = 3.0f;

@interface CMStatusItemView () {
    NSRect circleIconRect;
}

@property (assign, nonatomic) BOOL isNewPasteboardItem;
- (void)newPastrboardItem:(NSNotification *)notification;
@end

@implementation CMStatusItemView

- (void)newPastrboardItem:(NSNotification *)notification {
    if (!self.isNewPasteboardItem && ![self.window isKeyWindow])
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
        circleIconRect = NSInsetRect(frame, CMNewItemIconPadding, CMNewItemIconPadding);
        
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
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:circleIconRect];
    [[NSColor blackColor] setStroke];
    [circlePath stroke];
    
    if (self.isNewPasteboardItem) {
        NSBezierPath *newItemCircle = [NSBezierPath bezierPathWithOvalInRect:
                                       CGRectInset(circleIconRect, CMNewItemIconPadding, CMNewItemIconPadding)];
        [[NSColor redColor] setStroke];
        [newItemCircle stroke];
    }
}

@end
