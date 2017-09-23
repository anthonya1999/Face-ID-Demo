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
    
    void *PreferencesUI = dlopen("/System/Library/PrivateFrameworks/PreferencesUI.framework/PreferencesUI", RTLD_LAZY);
    NSParameterAssert(PreferencesUI);
    
    Class PSUIPearlPasscodeController = objc_getClass("PSUIPearlPasscodeController");
    NSParameterAssert(PSUIPearlPasscodeController);
    __kindof UIViewController *settingsPearlVC = [[PSUIPearlPasscodeController alloc] init];
    NSParameterAssert(settingsPearlVC);
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
    [settingsPearlVC.navigationItem setRightBarButtonItem:doneButton];
    
    _faceIsEnrolled = objc_msgSendBool(settingsPearlVC, sel_getUid("isEnrolled"));
    
    if (!_faceIsEnrolled) {
        Method isEnrolled_original = class_getInstanceMethod([settingsPearlVC class], sel_getUid("isEnrolled"));
        NSParameterAssert(isEnrolled_original);
        Method isEnrolled_override = class_getInstanceMethod([self class], @selector(isEnrolled_override));
        NSParameterAssert(isEnrolled_override);
        method_exchangeImplementations(isEnrolled_original, isEnrolled_override);
    }
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsPearlVC];
    [self presentViewController:navVC animated:YES completion:nil];
    
    dlclose(PreferencesUI);
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:^{
        _faceIsEnrolled = NO;
    }];
}

- (BOOL)isEnrolled_override {
    return YES;
}

@end

@implementation AVCaptureVideoPreviewLayer (Private)

- (void)setVideoPreviewFilters:(id)filters {
    /* Do nothing AT ALL or the entire thing will break!
     We can't add Apple entitlements :( */
}

@end
