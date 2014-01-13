//
//  CMAppDelegate.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMAppDelegate.h"
#import "CMChecker.h"
#import "CMStatusItemView.h"

@interface CMAppDelegate () <CMStatusItemViewDelegate>
- (void)resignKeyWindow;
@end
@implementation CMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    // Insert code here to initialize your application
    _appStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    CMStatusItemView *statusView = [[CMStatusItemView alloc] init];
    statusView.delegate = self;
    _appStatusItem.view = statusView;
    
    [[CMChecker sharedClipboardChecker] seedChecker];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignKeyWindow)
                                                 name:NSWindowDidResignKeyNotification object:statusView.window];
    */
}

- (void)resignKeyWindow {
    if ([_cbViewController.popover isShown])
        [_cbViewController.popover close];
    
}

#pragma mark -
#pragma mark StatusItem View Delegate

- (void)viewDidClicked:(NSView *)view {
    if (_cbViewController.popover.shown)
        [self.cbViewController.popover close];
    else
        [self.cbViewController.popover showRelativeToRect:view.frame
                                                   ofView:view
                                            preferredEdge:NSMinYEdge];
}


@end
