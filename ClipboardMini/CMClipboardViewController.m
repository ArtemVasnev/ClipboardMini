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


#define kFileItemCellNibName @"CMFileItemCell"
#define kTextItemCellNibName @"CMTextItemCell"

#define SearchRegExPattern(ENTRY) ([NSString stringWithFormat:@"\\b%@[\\w-]*", ENTRY])



@interface CMClipboardViewController () <CMItemsContentScrollViewDelegate, CMItemsContentScrollViewDataSource> {
    
    NSMutableArray *_allClipboardItems;
    NSMutableArray *_textClipboardItems;
    NSMutableArray *_fileClipboardItems;
    
    NSArray *_suggestions;
    
    CGSize emptyPopoverSize;
    BOOL _skipTextEditorUpdate;
}

- (void)newPastrboardItem:(NSNotification *)notification;

- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem;
- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem;

- (void)selectFileItem:(CMClipboardFileItem *)fileItem;
- (void)selectTextItem:(CMClipboardTextItem *)textItem;

- (BOOL)isRepeatedFile:(NSURL *)fileUrl;
- (BOOL)isRepeatedClipboardText:(NSString *)cText;

- (void)updateTextEditor:(NSText *)tEditor withText:(NSString *)text;
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
    _popover.contentSize = NSMakeSize(emptyPopoverSize.width, newHeight);
    
    [settingsView.documentView setHidden:NO];
}


#pragma mark -
#pragma mark Creation and Handling Menu Items
- (NSView *)itemCellForClipboardFileItem:(CMClipboardFileItem *)fileItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kFileItemCellNibName bundle:nil];
    
    CMFileItemCell *cell = (CMFileItemCell *)vc.view;
    [cell setFileUrl:fileItem.fileUrl icon:fileItem.icon];
    
    return cell;
}

- (NSView *)itemCellForClipboardTextItem:(CMClipboardTextItem *)textItem {
    
    NSViewController *vc = [[NSViewController alloc] initWithNibName:kTextItemCellNibName
                                                              bundle:nil];
    
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
        [contentView reload];
    }
}


#pragma mark -
#pragma mark Items ScrollView View Delegate

- (void)didChangeContentSize:(CGSize)newSize {
    _popover.contentSize = CGSizeMake(emptyPopoverSize.width, emptyPopoverSize.height + CGRectGetHeight(settingsView.bounds) + newSize.height);
}


- (void)didSelectItemAtRow:(NSInteger)row {
    [_popover close];
    CMClipboardItem *item;
    item = (contentView.suggestionMode) ? _suggestions[row] : _allClipboardItems[row];
    
    if (item.isFileItem)
        [self selectFileItem:(CMClipboardFileItem *)item];
    else
        [self selectTextItem:(CMClipboardTextItem *)item];
}

#pragma mark -
#pragma mark Items ScrollView Data Source

- (NSInteger)numberOfItemsInContentView:(CMItemsContentScrollView *)cView {
    NSInteger numberOfItems = (contentView.suggestionMode) ? _suggestions.count : _allClipboardItems.count;
    return numberOfItems;
}

- (NSView *)contentView:(CMItemsContentScrollView *)cView itemCellForRow:(NSInteger)row {
    CMClipboardItem *item;
    item = (contentView.suggestionMode) ? _suggestions[row] : _allClipboardItems[row];
    
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
    CMClipboardItem *cItem = [_suggestions firstObject];
    
    NSString *suggestionTitle = (cItem.isFileItem) ? [(CMClipboardFileItem *)cItem fileName] : [(CMClipboardTextItem *)cItem trimmedClipboardText];
    
    NSRange suggestionRange = [self rangeOfFirstMathForRegExPattern:SearchRegExPattern(editor.string) inString:suggestionTitle];
    
    NSInteger currentLenght = editor.string.length;
    
    editor.string = [suggestionTitle substringWithRange:suggestionRange];
    editor.selectedRange = NSMakeRange(currentLenght, editor.string.length - currentLenght);
}

- (void)updateTextEditor:(NSText *)tEditor withText:(NSString *)text {
    
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
    NSMutableArray *suggestions = [@[] mutableCopy];
    
    NSString *stringToMatch;
    
    for (CMClipboardItem *cItem in _allClipboardItems) {
        stringToMatch = (cItem.isFileItem) ? [(CMClipboardFileItem *)cItem fileName] : [(CMClipboardTextItem *)cItem trimmedClipboardText];
        NSRange matchRange = [self rangeOfFirstMathForRegExPattern:SearchRegExPattern(text) inString:stringToMatch];
        if (matchRange.location != NSNotFound)
            [suggestions addObject:cItem];
    }
    
    return [NSArray arrayWithArray:suggestions];
}


#pragma mark -
#pragma mark NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)obj {
    NSText *textEditor = [searchField currentEditor];
    
    contentView.suggestionMode = ([textEditor.string isEqualToString:@""]) ? NO : YES;
    
    if (contentView.suggestionMode) {
        _suggestions = [self suggestionsForText:textEditor.string];
        if (_suggestions.count > 0 && !_skipTextEditorUpdate)
            [self presentSuggestionPreviewInTextEditor:searchField.currentEditor];
    }
    _skipTextEditorUpdate = NO;
    [contentView reload];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(deleteBackward:) || commandSelector == @selector(deleteForward:)) {
        _skipTextEditorUpdate = YES;
        return NO;
    }
    
    if (commandSelector == @selector(insertNewline:) && ![control.stringValue isEqualToString:@""])
            [self didSelectItemAtRow:0];
    
    return NO;
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
    
    contentView.suggestionMode = NO;
    [contentView reload];
}


- (void)popoverDidClose:(NSNotification *)notification {
    _suggestions = nil;
    if (settingsView.isShowed)
        settingsView.isShowed = NO;
}

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    _popover = [[NSPopover alloc] init];
    _popover.delegate = self;
    _popover.contentViewController = self;
    _popover.behavior = NSPopoverBehaviorTransient;
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
