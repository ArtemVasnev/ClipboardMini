//
//  CMAppDelegate.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CMMenuController;
@interface CMAppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *_appStatusItem;
}
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet CMMenuController *menuController;

@end
