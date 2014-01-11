//
//  CMMenu.m
//  ClipboardMini
//
//  Created by Artem on 10/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMMenu.h"

@implementation CMMenu


- (void)clear {
    
    NSArray *menuItems = [NSArray arrayWithArray:self.itemArray];
    
    for (NSMenuItem *item in menuItems)
        if (item.tag != 1000)
            [self removeItem:item];

    menuItems = nil;
}

- (void)reload {
    if (!_dataSource) {
        [NSException raise:NSGenericException format:@"No data source provided"];
        return;
    }
    
    if ([self.itemArray count] > 1)
        [self clear];
    
    NSUInteger menuItemCount = [_dataSource numberOfItemsInMenu:self];
    
    for (NSUInteger idx = 1; idx <= menuItemCount; idx++) {
        NSMenuItem *menuItem = [_dataSource menu:self menuItemForRow:(idx - 1)];
        [self insertItem:menuItem atIndex:idx];
    }
    
}

@end
