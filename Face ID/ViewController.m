//
//  ViewController.m
//  Teest
//
//  Created by Anthony Agatiello on 9/19/17.
//  Copyright © 2017 Anthony Agatiello. All rights reserved.
//

#import "ViewController.h"
#include <dlfcn.h>

@import ObjectiveC;

@implementation ViewController

- (IBAction)showFaceID:(UIButton *)button {
    void *PreferencesUI = dlopen("/System/Library/PrivateFrameworks/PreferencesUI.framework/PreferencesUI", RTLD_LAZY);
    NSParameterAssert(PreferencesUI);
    
    Class PSUIPearlPasscodeController = objc_getClass("PSUIPearlPasscodeController");
    NSParameterAssert(PSUIPearlPasscodeController);
    __kindof UIViewController *settingsPearlVC = [[PSUIPearlPasscodeController alloc] init];
    NSParameterAssert(settingsPearlVC);
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
    [settingsPearlVC.navigationItem setRightBarButtonItem:doneButton];
    
    if (!_displayedControllerOnce) {
        AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        if ([videoPreviewLayer respondsToSelector:sel_getUid("setVideoPreviewFilters:")]) {
            NSLog(@"Overriding setVideoPreviewFilters:");
            Method setVideoPreviewFilters_original = class_getInstanceMethod([videoPreviewLayer class], sel_getUid("setVideoPreviewFilters:"));
            NSParameterAssert(setVideoPreviewFilters_original);
            Method setVideoPreviewFilters_override = class_getInstanceMethod([self class], @selector(setVideoPreviewFilters_override));
            NSParameterAssert(setVideoPreviewFilters_override);
            method_exchangeImplementations(setVideoPreviewFilters_original, setVideoPreviewFilters_override);
        }
    }
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsPearlVC];
    [self presentViewController:navVC animated:YES completion:^{
        _displayedControllerOnce = YES;
    }];
    
    dlclose(PreferencesUI);
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setVideoPreviewFilters_override {
    // Do nothing AT ALL or the entire thing will break! We can't add Apple entitlements :(
}

@end
