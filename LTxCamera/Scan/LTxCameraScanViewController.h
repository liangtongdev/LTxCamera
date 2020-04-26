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

@property (nonatomic, copy) LTxCameraStringCallbackBlock scanCallback;

-(void)scanCompleteWithQRCode:(NSString*)qrCode;


#pragma mark - 扫描框设置

//扫描框四条边的颜色和宽度
@property (nonatomic, strong) UIColor* borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

//扫描框四个角的颜色和宽度
@property (nonatomic, strong) UIColor* cornerColor;
@property (nonatomic, assign) CGFloat cornerWidth;
@property (nonatomic, assign) CGFloat cornerLength;

//动画图片
@property (nonatomic, strong) UIImage* scanAnimateImage;
@property (nonatomic, assign) CGFloat scanAnimateImageHeight;


@end
