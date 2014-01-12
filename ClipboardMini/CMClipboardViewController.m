//
//  CMMenuController.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMClipboardViewController.h"
#import "CMChecker.h"

#import "CMFileItemCell.h"
#import "CMTextItemCell.h"
#import "CMClipboardItem.h"
#import "CMItemsContentView.h"

#import "NSMutableArray+Helpers.h"
#import "NSURL+Helpers.h"


#define kFileItemCellNibName @"CMFileItemCell"
#define kTextItemCellNibName @"CMTextItemCell"



@interface CMClipboardViewController () <CMItemsContentViewDelegate, CMItemsContentViewDataSource> {
    
    NSMutableArray *_allClipboardItems;
    NSMutableArray *_textClipboardItems;
    NSMutableArray *_fileClipboardItems;
    
    NSArray *_suggestions;
    
    CGSize emptyPopoverSize;
    
}
@property (nonatomic, assign) BOOL isSuggestionMode;

- (void)newPastrboardItem:(NSNotification *)notification;


- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem;
- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem;

- (void)selectFileItem:(CMClipboardFileItem *)fileItem;
- (void)selectTextItem:(CMClipboardTextItem *)textItem;

- (BOOL)isRepeatedFile:(NSURL *)fileUrl;
- (BOOL)isRepeatedClipboardText:(NSString *)cText;


- (void)updateTextEditor:(NSText *)tEditor withText:(NSString *)text;
- (NSArray *)suggestionsForText:(NSString *)text;

@end


@implementation CMClipboardViewController

#pragma mark -
#pragma mark Creation and Handling Menu Items
- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kFileItemCellNibName bundle:nil];
    
    CMFileItemCell *cell = (CMFileItemCell *)vc.view;
    [cell setFileUrl:fileItem.fileUrl icon:fileItem.icon];
    
    return cell;
}

- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem {
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kTextItemCellNibName bundle:nil];
    
    CMTextItemCell *cell = (CMTextItemCell *)vc.view;
    [cell setClipboardText:textItem.trimmedClipboardText];
    
    return cell;
}

- (void)selectFileItem:(CMClipboardFileItem *)fileItem {
    [[NSWorkspace sharedWorkspace] openURL:fileItem.fileUrl];
    [_allClipboardItems moveObjectToBegining:fileItem];
}

- (void)selectTextItem:(CMClipboardTextItem *)textItem {
    [[CMChecker sharedClipboardChecker] stopChecker];
    
    NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
    [pBoard clearContents];
    [pBoard writeObjects:@[textItem.clipboardText]];
    [_allClipboardItems moveObjectToBegining:textItem];
    
    [[CMChecker sharedClipboardChecker] seedChecker];
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
#pragma mark ItemsContent View Delegate

- (void)didChangeContentSize:(CGSize)newSize {
    NSSize targetSize = CGSizeMake(emptyPopoverSize.width, emptyPopoverSize.height + newSize.height);
    _popover.contentSize = targetSize;
    [self.view layoutSubtreeIfNeeded];
}


- (void)didSelectItemAtRow:(NSInteger)row {
    [_popover close];
    CMClipboardItem *item;
    item = (_isSuggestionMode) ? _suggestions[row] : _allClipboardItems[row];
    
    if (item.isFileItem)
        [self selectFileItem:(CMClipboardFileItem *)item];
    else
        [self selectTextItem:(CMClipboardTextItem *)item];
}


#pragma mark -
#pragma mark ItemsContent View Data Source

- (NSInteger)numberOfItemsInContentView:(CMItemsContentView *)cView {
    NSInteger numberOfItems = (_isSuggestionMode) ? _suggestions.count : _allClipboardItems.count;
    return numberOfItems;
}

- (NSView *)contentView:(CMItemsContentView *)cView itemCellForRow:(NSInteger)row {
    CMClipboardItem *item;
    item = (_isSuggestionMode) ? _suggestions[row] : _allClipboardItems[row];
    
    NSView *itemCell = nil;
    if (item.isFileItem)
        itemCell = [self itemCellForClipboardFileItem:(CMClipboardFileItem *)item];
    else
        itemCell = [self itemCellForClipboardTextItem:(CMClipboardTextItem *)item];
    return itemCell;
}



#pragma mark -
#pragma mark Suggestions


- (void)updateTextEditor:(NSText *)tEditor withText:(NSString *)text {
    
}

// Looking item for presice file name,
// Same for text by this time
// Should change to search by words at future
- (NSArray *)suggestionsForText:(NSString *)text {
    NSMutableArray *suggestions = [@[] mutableCopy];
    
    NSRange matchRange;
    NSString *textToMatch;
    for (CMClipboardItem *cItem in _allClipboardItems) {
        textToMatch = (cItem.isFileItem) ? [(CMClipboardFileItem *)cItem fileName] : [(CMClipboardTextItem *)cItem trimmedClipboardText];
        matchRange = [textToMatch rangeOfString:text options:NSCaseInsensitiveSearch];
        
        if (matchRange.location == 0)
            [suggestions addObject:cItem];
    }
    
    return [NSArray arrayWithArray:suggestions];
}


#pragma mark -
#pragma mark NSTextField Delegate


- (void)controlTextDidChange:(NSNotification *)obj {
    NSText *textEditor = [searchField currentEditor];
    
    self.isSuggestionMode = ([textEditor.string isEqualToString:@""]) ? NO : YES;
    
    if (_isSuggestionMode) {
        _suggestions = [self suggestionsForText:textEditor.string];
        if (_suggestions.count == 0) {
            [contentView clear];
            return;
        } else {
            //            [contentView reload];
        }
        //        return;
    }
//    [contentView clear];
    [contentView reload];
}


#pragma mark -
#pragma mark NSPopover Delegate

- (void)popoverWillShow:(NSNotification *)notification {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPopoverSize = _popover.contentSize;
    });
    
    [NSApp activateIgnoringOtherApps:YES];
    [searchField becomeFirstResponder];
    searchField.stringValue = @"";
    
    _isSuggestionMode = NO;
    [contentView reload];
}

- (void)popoverDidClose:(NSNotification *)notification {
    [contentView clear];
}


#pragma mark -
#pragma mark Lifecycle



- (void)awakeFromNib {
    _popover = [[NSPopover alloc] init];
    _popover.delegate = self;
    _popover.contentViewController = self;
    _popover.behavior = NSPopoverBehaviorApplicationDefined;
}

- (id)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPastrboardItem:)
                                                     name:ClipboardChecherNewItemNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
