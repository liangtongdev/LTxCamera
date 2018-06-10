//
//  LTxCameraUtil.h
//  LTxCamera
//
//  Created by liangtong on 2018/3/2.
//  Copyright © 2018年 liangtong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#define LTxImageWithName(imageName)  [UIImage imageWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"LTxCamera.bundle/%@",imageName] ofType:@"png"]]
typedef void (^LTxCameraBOOLAndPHAssetCallbackBlock)(BOOL,PHAsset *);
typedef void (^LTxCameraImageURLAndPHAssetCallbackBlock)(UIImage*,NSURL*,PHAsset *);
typedef void (^LTxCameraStringCallbackBlock)(NSString *);

@interface LTxCameraUtil : NSObject

/**
 * 打开手电筒
 **/
+ (void)openFlashlight;

/**
 * 关闭手电筒
 **/
+ (void)closeFlashlight;

/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *)image completion:(LTxCameraBOOLAndPHAssetCallbackBlock)completion;

/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *)url completion:(LTxCameraBOOLAndPHAssetCallbackBlock)completion;

@end
