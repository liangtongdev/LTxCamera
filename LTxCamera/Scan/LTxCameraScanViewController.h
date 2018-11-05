//
//  LTxCameraScanViewController.h
//  LTxCamera
//
//  Created by liangtong on 2018/4/26.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LTxCameraScanView.h"

@interface LTxCameraScanViewController : UIViewController

@property (nonatomic, assign) LTxCameraStringCallbackBlock scanCallback;

-(void)scanCompleteWithQRCode:(NSString*)qrCode;

@end
