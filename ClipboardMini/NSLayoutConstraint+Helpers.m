//
//  NSLayoutConstraint+Helpers.m
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "NSLayoutConstraint+Helpers.h"

@implementation NSLayoutConstraint (Helpers)

+ (NSLayoutConstraint *)heightConstraintWithConstant:(NSInteger)constant
                                             forItem:(NSView *)item {
    NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:item
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:constant];
    return hConstraint;
}

@end
