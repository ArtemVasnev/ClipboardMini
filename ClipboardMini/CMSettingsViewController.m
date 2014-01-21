//
//  CMSettingsViewController.m
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMSettingsViewController.h"

// CMChecher
static NSString * const CMCheckerUpdateInterval = @"CheckerUpdateInterval";
static NSString * const CMUpdateIntervalDidChangeNotification = @"CMUpdateIntervalDidChangeNotification";

// Item Scroll View
static NSString * const CMScrollViewVisibleRowNumber = @"VisibleRowNumber";
static NSString * const CMVisibleRowNumberDidChangeNotification = @"CMVisibleRowNumberDidChangeNotification";


@interface CMSettingsViewController ()

@end

@implementation CMSettingsViewController

- (void)setUpdateInterval:(NSInteger)updateInterval {
    _updateInterval = updateInterval;
  [[NSNotificationCenter defaultCenter] postNotificationName:CMUpdateIntervalDidChangeNotification
                                                      object:nil
                                                    userInfo:@{CMCheckerUpdateInterval: @(_updateInterval)}];
}

- (void)setNumberOfVisibleItems:(NSInteger)numberOfVisibleItems {
    _numberOfVisibleItems = numberOfVisibleItems;
    [[NSNotificationCenter defaultCenter] postNotificationName:CMVisibleRowNumberDidChangeNotification
                                                        object:nil
                                                      userInfo:@{CMScrollViewVisibleRowNumber: @(_numberOfVisibleItems)}];
}

- (id)init {
    self = [super initWithNibName:@"CMSettingsViewController" bundle:nil];
    if (self) {
        _numberOfVisibleItems = [[NSUserDefaults standardUserDefaults] integerForKey:CMScrollViewVisibleRowNumber];
        _updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CMCheckerUpdateInterval];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _numberOfVisibleItems = [[NSUserDefaults standardUserDefaults] integerForKey:CMScrollViewVisibleRowNumber];
        _updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CMCheckerUpdateInterval];
    }
    return self;
}

@end
