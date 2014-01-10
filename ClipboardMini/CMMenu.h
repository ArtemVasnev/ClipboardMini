//
//  CMMenu.h
//  ClipboardMini
//
//  Created by Artem on 10/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CMMenuDataSource;

@interface CMMenu : NSMenu
@property (nonatomic, weak) IBOutlet id <CMMenuDataSource> dataSource;
- (void)reload;
- (void)clear;
@end

@protocol CMMenuDataSource <NSObject>
- (NSMenuItem *)menu:(CMMenu *)menu menuItemForRow:(NSUInteger)row;
- (NSInteger)numberOfItemsInMenu:(CMMenu *)menu;
@end