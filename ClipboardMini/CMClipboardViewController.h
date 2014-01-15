//
//  CMMenuController.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMItemsContentScrollView;
@class CMSettingsScrollView;

@interface CMClipboardViewController : NSViewController <NSTextFieldDelegate, NSPopoverDelegate> {
    __weak IBOutlet CMItemsContentScrollView *contentView;
    __weak IBOutlet NSSearchField *searchField;
    __weak IBOutlet CMSettingsScrollView *settingsView;
    
    NSLayoutConstraint *_contentViewHeightConstraint;
}
@property (nonatomic, strong) NSPopover *popover;
- (IBAction)displaySettings:(id)sender;

@end
