//
//  CMTextMenuItemCell.h
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMHighlightingView.h"

@interface CMTextMenuItemCell : CMHighlightingView {
    __weak IBOutlet NSTextField *textLabel;
}

- (void)setClipboardText:(NSString *)text;

@end
