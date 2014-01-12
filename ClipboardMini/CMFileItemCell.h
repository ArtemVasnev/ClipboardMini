//
//  CMMenuItemCell.h
//  ClipboardMini
//
//  Created by Artem on 03/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMHighlightingView.h"

@interface CMFileItemCell : CMHighlightingView {
    __weak IBOutlet NSTextField *titleLabel;
    __weak IBOutlet NSTextField *filePathLabel;
    __weak IBOutlet NSImageView *iconView;
    __weak IBOutlet NSProgressIndicator *spinner;
}


- (void)setFileUrl:(NSURL *)fileUrl;

@end
