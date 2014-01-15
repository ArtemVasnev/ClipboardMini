//
//  CMSettingsViewController.h
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CMSettingsViewController : NSViewController
@property (nonatomic, assign) NSInteger numberOfVisibleItems;
@property (nonatomic, assign) NSInteger updateInterval;

@end
