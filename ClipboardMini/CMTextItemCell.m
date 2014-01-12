//
//  CMTextMenuItemCell.m
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMTextItemCell.h"

@implementation CMTextItemCell

#pragma mark -
#pragma mark Public

- (void)setClipboardText:(NSString *)text {
    [textField setStringValue:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

#pragma mark -
#pragma mark Lifecycle

@end
