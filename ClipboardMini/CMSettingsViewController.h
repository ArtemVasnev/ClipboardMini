//
//  CMSettingsViewController.h
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CMSettingsViewController : NSViewController
@property (assign, nonatomic) NSInteger numberOfVisibleItems;
@property (assign, nonatomic) NSInteger updateInterval;

@end
