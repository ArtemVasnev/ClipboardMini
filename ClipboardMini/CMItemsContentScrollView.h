//
//  CMItemsContentView.h
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol CMItemsContentScrollViewDelegate;
@protocol CMItemsContentScrollViewDataSource;

@interface CMItemsContentScrollView : NSScrollView {
//    __weak IBOutlet NSScrollView *contentScrollView;
    NSLayoutConstraint *_heightConstraint;
}
@property (nonatomic, assign) BOOL suggestionMode;
@property (nonatomic, weak) IBOutlet id <CMItemsContentScrollViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <CMItemsContentScrollViewDataSource> dataSource;

- (void)reload;

@end

@protocol CMItemsContentScrollViewDelegate <NSObject>
- (void)didSelectItemAtRow:(NSInteger)row;
- (void)didChangeContentSize:(NSSize)newSize;
@end

@protocol CMItemsContentScrollViewDataSource <NSObject>
- (NSInteger)numberOfItemsInContentView:(CMItemsContentScrollView *)contentView;
- (NSView *)contentView:(CMItemsContentScrollView *)contentView itemCellForRow:(NSInteger)row;
@end

