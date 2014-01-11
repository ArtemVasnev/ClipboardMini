//
//  CMMenuController.h
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMMenu.h"

@interface CMMenuController : NSObject <CMMenuDataSource, NSMenuDelegate, NSTextFieldDelegate>
@property (weak, nonatomic) IBOutlet CMMenu *menu;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;


@end
