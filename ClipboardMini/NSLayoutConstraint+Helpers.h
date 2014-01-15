//
//  NSLayoutConstraint+Helpers.h
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSLayoutConstraint (Helpers)
+ (NSLayoutConstraint *)heightConstraintWithConstant:(NSInteger)constant
                                             forItem:(NSView *)item;
@end
