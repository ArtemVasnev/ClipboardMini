//
//  CMTextMenuItemCell.m
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMTextMenuItemCell.h"

@implementation CMTextMenuItemCell

#pragma mark -
#pragma mark Property


#pragma mark -
#pragma mark Public

- (void)setClipboardText:(NSString *)text {
    [textLabel setStringValue:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

#pragma mark -
#pragma mark Mouse Events


#pragma mark -
#pragma mark Lifecycle

@end
