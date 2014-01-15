//
//  CMSettingsViewController.m
//  ClipboardMini
//
//  Created by Artem on 14/01/14.
//  Copyright (c) 2014 Artem. All rights reserved.
//

#import "CMSettingsViewController.h"

// CMChecher
static NSString * const CheckerUpdateInterval = @"CheckerUpdateInterval";
static NSString * const CMUpdateIntervalDidChangeNotification = @"CMUpdateIntervalDidChangeNotification";

// Item Scroll View

static NSString * const ScrollViewVisibleRowNumber = @"VisibleRowNumber";
static NSString * const CMVisibleRowNumberDidChangeNotification = @"CMVisibleRowNumberDidChangeNotification";


@interface CMSettingsViewController ()

@end

@implementation CMSettingsViewController

- (void)setUpdateInterval:(NSInteger)updateInterval {
    _updateInterval = updateInterval;
  [[NSNotificationCenter defaultCenter] postNotificationName:CMUpdateIntervalDidChangeNotification
                                                      object:nil
                                                    userInfo:@{CheckerUpdateInterval: @(_updateInterval)}];
}

- (void)setNumberOfVisibleItems:(NSInteger)numberOfVisibleItems {
    _numberOfVisibleItems = numberOfVisibleItems;
    [[NSNotificationCenter defaultCenter] postNotificationName:CMVisibleRowNumberDidChangeNotification
                                                        object:nil
                                                      userInfo:@{ScrollViewVisibleRowNumber: @(_numberOfVisibleItems)}];
}

- (id)init {
    self = [super initWithNibName:@"CMSettingsViewController" bundle:nil];
    if (self) {
        _numberOfVisibleItems = [[NSUserDefaults standardUserDefaults] integerForKey:ScrollViewVisibleRowNumber];
        _updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CheckerUpdateInterval];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _numberOfVisibleItems = [[NSUserDefaults standardUserDefaults] integerForKey:ScrollViewVisibleRowNumber];
        _updateInterval = [[NSUserDefaults standardUserDefaults] integerForKey:CheckerUpdateInterval];
    }
    return self;
}

@end
