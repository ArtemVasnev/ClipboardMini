//
//  CMItemsContentView.h
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CMItemsContentViewDelegate;
@protocol CMItemsContentViewDataSource;

@interface CMItemsContentView : NSView {
    __weak IBOutlet NSScrollView *contentScrollView;
    NSLayoutConstraint *_heightConstraint;
}

@property (nonatomic, weak) IBOutlet id <CMItemsContentViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <CMItemsContentViewDataSource> dataSource;

- (void)reload;
- (void)clear;
@end

@protocol CMItemsContentViewDelegate <NSObject>
- (void)didSelectItemAtRow:(NSInteger)row;
- (void)didChangeContentSize:(NSSize)newSize;
@end

@protocol CMItemsContentViewDataSource <NSObject>
- (NSInteger)numberOfItemsInContentView:(CMItemsContentView *)cView;
- (NSView *)contentView:(CMItemsContentView *)cView itemCellForRow:(NSInteger)row;
@end

