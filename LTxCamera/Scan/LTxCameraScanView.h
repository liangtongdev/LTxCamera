//
//  LTxCameraScanView.h
//  LTxCamera
//
//  Created by liangtong on 2018/4/24.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"
/**
 * 二维码扫描界面
 * 外框 + 四个角
 **/

#define LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE 220

@interface LTxCameraScanView : UIView
@property (nonatomic, strong) UIColor* borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, strong) UIColor* cornerColor;
@property (nonatomic, assign) CGFloat cornerWidth;
@property (nonatomic, assign) CGFloat cornerLength;

@property (nonatomic, strong) UIImage* scanAnimateImage;
@property (nonatomic, assign) CGFloat scanAnimateImageHeight;


-(void)addTimer;
-(void)removeTimer;

-(void)brightnessLight:(BOOL)isNight;


@end
