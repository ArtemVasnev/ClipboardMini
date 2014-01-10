//
//  CMAppDelegate.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMAppDelegate.h"
#import "CMMenuController.h"
@implementation CMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _appStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_appStatusItem setTitle:@"Clipboard"];
    [_appStatusItem setMenu:[_menuController menu]];
}

@end
