//
//  CMMenuController.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMMenuController.h"
#import "CMClipboardChecker.h"
#import "CMFileMenuItemCell.h"
#import "CMTextMenuItemCell.h"
#import "CMClipboardItem.h"

#import "NSMutableArray+Helpers.h"
#import "NSURL+Helpers.h"

#define kMenuItemCellTag 1000
#define kFileMenuItemCellNibName @"CMFileMenuItemCell"
#define kTextMenuItemCellNibName @"CMTextMenuItemCell"

@interface CMMenuController ()  {
    
    NSMutableArray *_allClipboardItems;
    NSMutableArray *_textClipboardItems;
    NSMutableArray *_fileClipboardItems;
    
}
- (void)newPastrboardItem:(NSNotification *)notification;


- (NSMenuItem *)menuItemWithClipboardFileItem:(CMClipboardFileItem *)fileItem;
- (void)didSelectFileMenuItem:(id)sender;
- (NSMenuItem *)menuItemWithClipboardTextItem:(CMClipboardTextItem *)textItem;
- (void)didSelectTextMenuItem:(id)sender;

- (BOOL)isRepeatedFile:(NSURL *)fileUrl;
- (BOOL)isRepeatedClipboardText:(NSString *)cText;

@end

@implementation CMMenuController

#pragma mark -
#pragma mark Private
- (NSMenuItem *)menuItemWithClipboardFileItem:(CMClipboardFileItem *)fileItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kFileMenuItemCellNibName bundle:nil];
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    menuItem.view = vc.view;
    menuItem.representedObject = fileItem;
    
    [menuItem setTarget:self];
    [menuItem setAction:@selector(didSelectFileMenuItem:)];
    
    CMFileMenuItemCell *cell = (CMFileMenuItemCell *)vc.view;
    [cell setFileUrl:fileItem.fileUrl];
    
    return menuItem;
}

- (NSMenuItem *)menuItemWithClipboardTextItem:(CMClipboardTextItem *)textItem {
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kTextMenuItemCellNibName bundle:nil];
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    menuItem.view = vc.view;
    menuItem.representedObject = textItem;
    
    [menuItem setTarget:self];
    [menuItem setAction:@selector(didSelectTextMenuItem:)];
    
    CMTextMenuItemCell *cell = (CMTextMenuItemCell *)vc.view;
    [cell setClipboardText:textItem.clipboardText];
    
    return menuItem;
}

- (void)didSelectFileMenuItem:(id)sender {
    [_menu cancelTracking];
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    CMClipboardFileItem *fileItem = [menuItem representedObject];
    [[NSWorkspace sharedWorkspace] openURL:fileItem.fileUrl];
    [_allClipboardItems moveObjectToBegining:fileItem];
    
}

- (void)didSelectTextMenuItem:(id)sender {
    [[CMClipboardChecker sharedClipboardChecker] stopChecker];
    
    [_menu cancelTracking];
    
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    CMClipboardTextItem *textItem = [menuItem representedObject];
    NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
    [pBoard clearContents];
    [pBoard writeObjects:@[textItem.clipboardText]];
    [_allClipboardItems moveObjectToBegining:textItem];
    
    [[CMClipboardChecker sharedClipboardChecker] seedChecker];
}

- (BOOL)isRepeatedFile:(NSURL *)fileUrl {
    __block BOOL isRepeated = NO;
    
    if (!_fileClipboardItems) {
        _fileClipboardItems = [@[] mutableCopy];
        return isRepeated;
    }
    
    [_fileClipboardItems enumerateObjectsUsingBlock:^(CMClipboardFileItem *fileItem, NSUInteger idx, BOOL *stop) {
        
        if ([[fileUrl path] isEqualToString:[fileItem.fileUrl path]]) {
            isRepeated = YES;
            *stop = YES;
        }
    }];
    
    return isRepeated;
}

- (BOOL)isRepeatedClipboardText:(NSString *)cText {
    __block BOOL isRepeated = NO;
    
    if (!_textClipboardItems) {
        _textClipboardItems = [@[] mutableCopy];
        return isRepeated;
    }
    
    [_textClipboardItems enumerateObjectsUsingBlock:^(CMClipboardTextItem *textItem, NSUInteger idx, BOOL *stop) {
        
        if ([cText isEqualToString:[textItem clipboardText]]) {
            isRepeated = YES;
            *stop = YES;
        }
    }];
    
    return isRepeated;
}


#pragma mark -
#pragma mark Pasteboard Notifications

- (void)newPastrboardItem:(NSNotification *)notification {
    
    NSString *dataType = [[[notification userInfo] allKeys] objectAtIndex:0];
    NSString *clipboardString = [[notification userInfo] objectForKey:dataType];
    
    CMClipboardItem *clipboardItem = nil;
    if (UTTypeConformsTo((__bridge CFStringRef)dataType, kUTTypeFileURL)) {
        NSURL *fileUrl = [NSURL URLWithString:clipboardString];
        if (![self isRepeatedFile:fileUrl]) {
            clipboardItem = [CMClipboardItem clipboardItemWithUrl:fileUrl];
            [_fileClipboardItems addObject:clipboardItem];
        }
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)dataType, kUTTypeText)) {
        if (![self isRepeatedClipboardText:clipboardString]) {
            clipboardItem = [CMClipboardItem clipboardItemWithText:clipboardString];
            [_textClipboardItems addObject:clipboardItem];
        }
    }
    
    
    if (clipboardItem) {
        if (!_allClipboardItems)
            _allClipboardItems = [@[] mutableCopy];
        
        [_allClipboardItems insertObject:clipboardItem atIndex:0];
    }
    
}

#pragma mark -
#pragma mark NSMenu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    [[CMClipboardChecker sharedClipboardChecker] stopChecker];
    [self.menu reload];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self.menu clear];
    [[CMClipboardChecker sharedClipboardChecker] seedChecker];
}

#pragma mark -
#pragma mark CMMenu Data source

- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
    return [_allClipboardItems count];
}

- (NSMenuItem *)menu:(CMMenu *)menu menuItemForRow:(NSUInteger)row {
    NSMenuItem *menuItem = nil;
    
    CMClipboardItem *clipboardItem = [_allClipboardItems objectAtIndex:row];
    
    if ([clipboardItem isFileItem])
        menuItem = [self menuItemWithClipboardFileItem:(CMClipboardFileItem *)clipboardItem];
    else
        menuItem = [self menuItemWithClipboardTextItem:(CMClipboardTextItem *)clipboardItem];
    
    return menuItem;
}


#pragma mark -
#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPastrboardItem:)
                                                     name:ClipboardChecherNewPasteboardItemNotification
                                                   object:nil];
        
        [[CMClipboardChecker sharedClipboardChecker] seedChecker];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
