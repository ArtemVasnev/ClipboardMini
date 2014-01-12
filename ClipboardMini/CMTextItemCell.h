//
//  CMTextMenuItemCell.h
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMHighlightingView.h"

@interface CMTextItemCell : CMHighlightingView {
    IBOutlet NSTextField *textField;
}

- (void)setClipboardText:(NSString *)text;

@end
