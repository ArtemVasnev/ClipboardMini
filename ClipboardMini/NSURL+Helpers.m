//
//  NSURL+Helpers.m
//  ClipboardMini
//
//  Created by Artem on 09/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "NSURL+Helpers.h"

@implementation NSURL (Helpers)
- (NSString *)fileName {
    return [[self.path stringByDeletingPathExtension] lastPathComponent];
}
@end
