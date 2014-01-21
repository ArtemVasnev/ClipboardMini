//
//  CMSettingsView.m
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMSettingsScrollView.h"
#import "CMSettingsViewController.h"
#import "NSLayoutConstraint+Helpers.h"

@interface CMSettingsScrollView () {
    CMSettingsViewController *settingsController;
}
@end

@implementation CMSettingsScrollView

#pragma mark -
#pragma mark Property
- (void)setIsShowed:(BOOL)show {
    
    CGFloat newHeight = 0;
    if (show) {
        settingsController = [[CMSettingsViewController alloc] init];
        [self.documentView addSubview:settingsController.view];
        newHeight = CGRectGetHeight(settingsController.view.bounds);
    } else {
        [settingsController.view removeFromSuperview];
        settingsController = nil;
    }
    
    [self removeConstraint:heightConstraint];
    heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:newHeight
                                                                 forItem:self];
    [self addConstraint:heightConstraint];
    
    _isShowed = show;
    [self layout];
}

#pragma mark -
#pragma mark Lifecycle
- (void)layout {
    [super layout];
    
    CGFloat docViewHeight = 0;
    if (settingsController) {
        settingsController.view.frame = settingsController.view.bounds;
        docViewHeight = CGRectGetHeight(settingsController.view.bounds);
    }
    
    [self.documentView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), docViewHeight)];
}

- (void)awakeFromNib {
    self.isShowed = NO;
    self.verticalScrollElasticity = NSScrollElasticityNone;
}

@end
