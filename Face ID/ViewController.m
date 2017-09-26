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
    BOOL (*objc_msgSendBool)(id self, SEL _cmd) = dlsym(RTLD_DEFAULT, "objc_msgSend");
    NSParameterAssert(objc_msgSendBool);
    
    void *PreferencesUI = dlopen("/System/Library/PrivateFrameworks/PreferencesUI.framework/PreferencesUI", RTLD_LAZY);
    NSParameterAssert(PreferencesUI);
    
    Class PSUIPearlPasscodeController = objc_getClass("PSUIPearlPasscodeController");
    NSParameterAssert(PSUIPearlPasscodeController);
    __kindof UIViewController *settingsPearlVC = [[PSUIPearlPasscodeController alloc] init];
    NSParameterAssert(settingsPearlVC);
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
    [settingsPearlVC.navigationItem setRightBarButtonItem:doneButton];
    
    if (objc_msgSendBool(settingsPearlVC, sel_getUid("isEnrolled")) == NO) {
        // Make Face ID always enrolled (just always return true)
        if ([settingsPearlVC respondsToSelector:sel_getUid("isEnrolled")]) {
            NSLog(@"Face ID is not enrolled...overriding!");
            Method isEnrolled_original = class_getInstanceMethod([settingsPearlVC class], sel_getUid("isEnrolled"));
            NSParameterAssert(isEnrolled_original);
            Method isEnrolled_override = class_getInstanceMethod([self class], @selector(isEnrolled_override));
            NSParameterAssert(isEnrolled_override);
            method_exchangeImplementations(isEnrolled_original, isEnrolled_override);
        }
        AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        if ([videoPreviewLayer respondsToSelector:sel_getUid("setVideoPreviewFilters:")]) {
            NSLog(@"Overriding setVideoPreviewFilters:");
            Method setVideoPreviewFilters_original = class_getInstanceMethod([videoPreviewLayer class], sel_getUid("setVideoPreviewFilters:"));
            NSParameterAssert(setVideoPreviewFilters_original);
            Method setVideoPreviewFilters_override = class_getInstanceMethod([self class], @selector(setVideoPreviewFilters_override));
            NSParameterAssert(setVideoPreviewFilters_override);
            method_exchangeImplementations(setVideoPreviewFilters_original, setVideoPreviewFilters_override);
        }
        if ([settingsPearlVC respondsToSelector:sel_getUid("numberOfAppsUsingPearl")]) {
            NSLog(@"Overriding numberOfAppsUsingPearl");
            Method numberOfAppsUsingPearl_original = class_getInstanceMethod([settingsPearlVC class], sel_getUid("numberOfAppsUsingPearl"));
            NSParameterAssert(numberOfAppsUsingPearl_original);
            Method numberOfAppsUsingPearl_override = class_getInstanceMethod([self class], @selector(numberOfAppsUsingPearl_override));
            NSParameterAssert(numberOfAppsUsingPearl_override);
            method_exchangeImplementations(numberOfAppsUsingPearl_original, numberOfAppsUsingPearl_override);
        }
    }
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsPearlVC];
    [self presentViewController:navVC animated:YES completion:nil];
    
    dlclose(PreferencesUI);
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isEnrolled_override {
    return YES;
}

- (unsigned long long)numberOfAppsUsingPearl_override {
    return 5;
}

- (void)setVideoPreviewFilters_override {
    // Do nothing AT ALL or the entire thing will break! We can't add Apple entitlements :(
}

@end
