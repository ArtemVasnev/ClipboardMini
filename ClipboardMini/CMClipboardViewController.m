//
//  CMMenuController.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMClipboardViewController.h"
#import "CMChecker.h"
#import <QuartzCore/QuartzCore.h>

#import "CMFileItemCell.h"
#import "CMTextItemCell.h"
#import "CMClipboardItem.h"
#import "CMItemsContentScrollView.h"
#import "CMSettingsScrollView.h"

#import "NSMutableArray+Helpers.h"
#import "NSURL+Helpers.h"


static NSString * const CMFileItemCellNibName = @"CMFileItemCell";
static NSString * const CMTextItemCellNibName = @"CMTextItemCell";

#define SearchRegExPattern(ENTRY) ([NSString stringWithFormat:@"\\b%@[\\w-]*", ENTRY])

@interface CMClipboardViewController () <CMItemsContentScrollViewDelegate, CMItemsContentScrollViewDataSource> {
    
    NSMutableArray *allClipboardItems;
    NSMutableArray *textClipboardItems;
    NSMutableArray *fileClipboardItems;
    
    NSArray *suggestions;
    
    CGSize emptyPopoverSize;
    BOOL skipTextEditorUpdate;
}

- (void)newPastrboardItem:(NSNotification *)notification;

- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem;
- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem;

- (void)selectFileItem:(CMClipboardFileItem *)fileItem;
- (void)selectTextItem:(CMClipboardTextItem *)textItem;

- (BOOL)isRepeatedFile:(NSURL *)fileUrl;
- (BOOL)isRepeatedClipboardText:(NSString *)cText;

- (void)presentSuggestionPreviewInTextEditor:(NSText *)editor;
- (NSRange)rangeOfFirstMathForRegExPattern:(NSString *)pattern inString:(NSString *)stringToMatch;
- (NSArray *)suggestionsForText:(NSString *)text;

@end


@implementation CMClipboardViewController

#pragma mark -
#pragma mark Settings

- (void)displaySettings:(id)sender {
    
    [settingsView.documentView setHidden:YES];
    
    settingsView.isShowed = !settingsView.isShowed;
    NSInteger newHeight = emptyPopoverSize.height + CGRectGetHeight(contentView.bounds) + CGRectGetHeight([settingsView.documentView bounds]);
    self.popover.contentSize = NSMakeSize(emptyPopoverSize.width, newHeight);
    
    [settingsView.documentView setHidden:NO];
}


#pragma mark -
#pragma mark Creation and Handling Menu Items
- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:CMFileItemCellNibName bundle:nil];
    
    CMFileItemCell *cell = (CMFileItemCell *)vc.view;
    [cell setFileUrl:fileItem.fileUrl icon:fileItem.icon];
    
    return cell;
}

- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:CMTextItemCellNibName
                                                              bundle:nil];
    
    CMTextItemCell *cell = (CMTextItemCell *)vc.view;
    [cell setClipboardText:textItem.trimmedClipboardText];
    
    return cell;
}

- (void)selectFileItem:(CMClipboardFileItem *)fileItem {
    [[NSWorkspace sharedWorkspace] openURL:fileItem.fileUrl];
    [allClipboardItems moveObjectToBegining:fileItem];
}

- (void)selectTextItem:(CMClipboardTextItem *)textItem {
    [[CMChecker sharedClipboardChecker] stopChecker];
    
    NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
    [pBoard clearContents];
    [pBoard writeObjects:@[textItem.clipboardText]];
    [allClipboardItems moveObjectToBegining:textItem];
    
    [[CMChecker sharedClipboardChecker] seedChecker];
}


- (BOOL)isRepeatedFile:(NSURL *)fileUrl {

    
    if (!fileClipboardItems) {
        fileClipboardItems = [@[] mutableCopy];
        return NO;
    }
    
    __block BOOL isRepeated = NO;
    [fileClipboardItems enumerateObjectsUsingBlock:^(CMClipboardFileItem *fileItem, NSUInteger idx, BOOL *stop) {
        if ([[fileUrl path] isEqualToString:[fileItem.fileUrl path]]) {
            isRepeated = YES;
            *stop = YES;
        }
    }];
    
    return isRepeated;
}

- (BOOL)isRepeatedClipboardText:(NSString *)cText {

    if (!textClipboardItems) {
        textClipboardItems = [@[] mutableCopy];
        return NO;
    }
    
    __block BOOL isRepeated = NO;
    [textClipboardItems enumerateObjectsUsingBlock:^(CMClipboardTextItem *textItem, NSUInteger idx, BOOL *stop) {
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
            [fileClipboardItems addObject:clipboardItem];
        }
    } else if (UTTypeConformsTo((__bridge CFStringRef)dataType, kUTTypeText)) {
        if (![self isRepeatedClipboardText:clipboardString]) {
            clipboardItem = [CMClipboardItem clipboardItemWithText:clipboardString];
            [textClipboardItems addObject:clipboardItem];
        }
    }
    
    if (clipboardItem) {
        if (!allClipboardItems)
            allClipboardItems = [@[] mutableCopy];
        
        [allClipboardItems insertObject:clipboardItem atIndex:0];
        [contentView reload];
    }
}


#pragma mark -
#pragma mark Items ScrollView View Delegate

- (void)didChangeContentSize:(CGSize)newSize {
    self.popover.contentSize = CGSizeMake(emptyPopoverSize.width, emptyPopoverSize.height + CGRectGetHeight(settingsView.bounds) + newSize.height);
}


- (void)didSelectItemAtRow:(NSInteger)row {
    [self.popover close];
    CMClipboardItem *item;
    item = (contentView.suggestionMode) ? suggestions[row] : allClipboardItems[row];
    
    if (item.isFileItem)
        [self selectFileItem:(CMClipboardFileItem *)item];
    else
        [self selectTextItem:(CMClipboardTextItem *)item];
}

#pragma mark -
#pragma mark Items ScrollView Data Source

- (NSInteger)numberOfItemsInContentView:(CMItemsContentScrollView *)cView {
    NSInteger numberOfItems = (contentView.suggestionMode) ? suggestions.count : allClipboardItems.count;
    return numberOfItems;
}

- (NSView *)contentView:(CMItemsContentScrollView *)cView itemCellForRow:(NSInteger)row {
    CMClipboardItem *item;
    item = (contentView.suggestionMode) ? suggestions[row] : allClipboardItems[row];
    
    NSView *itemCell = nil;
    if (item.isFileItem)
        itemCell = [self itemCellForClipboardFileItem:(CMClipboardFileItem *)item];
    else
        itemCell = [self itemCellForClipboardTextItem:(CMClipboardTextItem *)item];
    return itemCell;
}


#pragma mark -
#pragma mark Suggestions

- (void)presentSuggestionPreviewInTextEditor:(NSText *)editor {
    CMClipboardItem *cItem = [suggestions firstObject];
    
    NSString *suggestionTitle = (cItem.isFileItem) ? [(CMClipboardFileItem *)cItem fileName] : [(CMClipboardTextItem *)cItem trimmedClipboardText];
    
    NSRange suggestionRange = [self rangeOfFirstMathForRegExPattern:SearchRegExPattern(editor.string) inString:suggestionTitle];
    
    NSInteger currentLenght = editor.string.length;
    
    editor.string = [suggestionTitle substringWithRange:suggestionRange];
    editor.selectedRange = NSMakeRange(currentLenght, editor.string.length - currentLenght);
}

- (NSRange)rangeOfFirstMathForRegExPattern:(NSString *)pattern inString:(NSString *)stringToMatch {
    __block NSRange matchedRange = NSMakeRange(NSNotFound, 0);
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    [regEx enumerateMatchesInString:stringToMatch options:0 range:NSMakeRange(0, stringToMatch.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        matchedRange = [result range];
        *stop = YES;
    }];
    return matchedRange;
    
}

- (NSArray *)suggestionsForText:(NSString *)text {
    
    NSMutableArray *suggestionsArray = [@[] mutableCopy];
    
    NSString *stringToMatch;
    
    for (CMClipboardItem *cItem in allClipboardItems) {
        stringToMatch = (cItem.isFileItem) ? [(CMClipboardFileItem *)cItem fileName] : [(CMClipboardTextItem *)cItem trimmedClipboardText];
        NSRange matchRange = [self rangeOfFirstMathForRegExPattern:SearchRegExPattern(text) inString:stringToMatch];
        
        if (matchRange.location != NSNotFound)
            [suggestionsArray addObject:cItem];
    }
    
    return [NSArray arrayWithArray:suggestionsArray];
}


#pragma mark -
#pragma mark NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)obj {
    NSText *textEditor = [searchField currentEditor];
    
    contentView.suggestionMode = ([textEditor.string isEqualToString:@""]) ? NO : YES;
    
    if (contentView.suggestionMode) {
        suggestions = [self suggestionsForText:textEditor.string];
        if (suggestions.count > 0 && !skipTextEditorUpdate)
            [self presentSuggestionPreviewInTextEditor:searchField.currentEditor];
    }
    skipTextEditorUpdate = NO;
    [contentView reload];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(deleteBackward:)
        || commandSelector == @selector(deleteForward:))
        skipTextEditorUpdate = YES;
    
    if (commandSelector == @selector(insertNewline:)
        && ![control.stringValue isEqualToString:@""])
        [self didSelectItemAtRow:0];
    
    return NO;
}

#pragma mark -
#pragma mark NSPopover Delegate

- (void)popoverWillShow:(NSNotification *)notification {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPopoverSize = self.popover.contentSize;
    });
    
    [NSApp activateIgnoringOtherApps:YES];
    [searchField becomeFirstResponder];
    searchField.stringValue = @"";
    
    contentView.suggestionMode = NO;
    [contentView reload];
}


- (void)popoverDidClose:(NSNotification *)notification {
    suggestions = nil;
    if (settingsView.isShowed)
        settingsView.isShowed = NO;
}

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    self.popover = [[NSPopover alloc] init];
    self.popover.delegate = self;
    self.popover.contentViewController = self;
    self.popover.behavior = NSPopoverBehaviorTransient;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPastrboardItem:)
                                                     name:CMClipboardNewItemNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
