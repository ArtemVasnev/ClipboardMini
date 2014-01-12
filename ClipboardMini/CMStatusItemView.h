//
//  CMStatusItemView.h
//  ClipboardMini
//
//  Created by Artem on 11/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CMStatusItemViewDelegate;
@interface CMStatusItemView : NSView

@property (nonatomic, weak) id <CMStatusItemViewDelegate> delegate;
@end

@protocol CMStatusItemViewDelegate <NSObject>
- (void)viewDidClicked:(NSView *)view;
@end
