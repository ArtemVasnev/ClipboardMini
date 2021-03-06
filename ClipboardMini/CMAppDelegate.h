//
//  CMAppDelegate.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSWindow+canBecomeKeyWindow.h"
#import "CMClipboardViewController.h"

@interface CMAppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *appStatusItem;
}
@property (assign) IBOutlet NSWindow *window;
@property (weak, nonatomic) IBOutlet CMClipboardViewController *cbViewController;
@end
