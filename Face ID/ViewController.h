//
//  ViewController.h
//  Teest
//
//  Created by Anthony Agatiello on 9/19/17.
//  Copyright © 2017 Anthony Agatiello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

- (BOOL)isEnrolled_override;

@end

@interface AVCaptureVideoPreviewLayer (Private)

- (void)setVideoPreviewFilters:(id)filters;

@end
