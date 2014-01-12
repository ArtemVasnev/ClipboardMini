//
//  CMMenuController.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CMItemsContentView;
@interface CMClipboardViewController : NSViewController <NSTextFieldDelegate, NSPopoverDelegate> {
    __weak IBOutlet CMItemsContentView *contentView;
    __weak IBOutlet NSSearchField *searchField;
}
@property (nonatomic, strong) NSPopover *popover;


@end
