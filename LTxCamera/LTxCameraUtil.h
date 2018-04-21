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

#define LTxImageWithName(imageName)  [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LTxCamera.bundle/%@",imageName] ofType:@"png"]]
typedef void (^LTxSipprImageURLAndPHAssetCallbackBlock)(UIImage*,NSURL*,PHAsset *);


@interface LTxCameraUtil : NSObject

/** 打开手电筒 */
+ (void)openFlashlight;
/** 关闭手电筒 */
+ (void)closeFlashlight;

/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion;

/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL suc, PHAsset *asset))completion;

@end
