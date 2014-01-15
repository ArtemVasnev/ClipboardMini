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
    CMSettingsViewController *_settingsController;
}
@end


@implementation CMSettingsScrollView

#pragma mark -
#pragma mark Property
- (void)setIsShowed:(BOOL)show {
    
    CGFloat newHeight = 0;
    if (show) {
        _settingsController = [[CMSettingsViewController alloc] init];
        [self.documentView addSubview:_settingsController.view];
        newHeight = CGRectGetHeight(_settingsController.view.bounds);
    } else {
        [_settingsController.view removeFromSuperview];
        _settingsController = nil;
    }
    
    [self removeConstraint:_heightConstraint];
    _heightConstraint = [NSLayoutConstraint heightConstraintWithConstant:newHeight
                                                                 forItem:self];
    [self addConstraint:_heightConstraint];
    
    _isShowed = show;
    [self layout];
}

#pragma mark -
#pragma mark Lifecycle
- (void)layout {
    [super layout];
    
    CGFloat docViewHeight = 0;
    if (_settingsController) {
        _settingsController.view.frame = _settingsController.view.bounds;
        docViewHeight = CGRectGetHeight(_settingsController.view.bounds);
    }
    
    [self.documentView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), docViewHeight)];
}

- (void)awakeFromNib {
    self.isShowed = NO;
    self.verticalScrollElasticity = NSScrollElasticityNone;
}

@end
