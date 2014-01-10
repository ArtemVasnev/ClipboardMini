//
//  NSMutableArray+Helpers.m
//  ClipboardMini
//
//  Created by Artem on 02/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "NSMutableArray+Helpers.h"

@implementation NSMutableArray (Helpers)
- (void)moveObjectToBegining:(id)obj {
    [self removeObject:obj];
    [self insertObject:obj atIndex:0];
}

- (void)moveObjectToEnd:(id)obj {
    [self removeObject:obj];
    [self addObject:obj];
}

@end
