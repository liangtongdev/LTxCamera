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
#import "NSBundle+LTxCamera.h"

#import "LTxCameraPhotoPickerProtocol.h"//协议

/**Model**/
#import "LTxCameraAlbumModel.h"//相册
#import "LTxCameraAssetModel.h"//相片

#define LTxImageWithName(imageName)  [UIImage imageWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"LTxCamera.bundle/%@",imageName] ofType:@"png"]]
typedef void (^LTxCameraBOOLAndPHAssetCallbackBlock)(BOOL,PHAsset *);
typedef void (^LTxCameraImageURLAndPHAssetCallbackBlock)(UIImage*,NSURL*,PHAsset *);
typedef void (^LTxCameraPathAndStringCallbackBlock)(NSString*,NSString *);
typedef void (^LTxCameraImagePathAndStringCallbackBlock)(UIImage*,NSString*,NSString *);
typedef void (^LTxCameraAVPlayerItemAndDictionaryCallbackBlock)(AVPlayerItem*,NSDictionary *);
typedef void (^LTxCameraStringCallbackBlock)(NSString *);
typedef void (^LTxCameraCallbackBlock)(void);
typedef void (^LTxCameraBOOLCallbackBlock)(BOOL);

@interface LTxCameraUtil : NSObject

#pragma mark - 手电筒
/**
 * 打开手电筒
 **/
+ (void)openFlashlight;

/**
 * 关闭手电筒
 **/
+ (void)closeFlashlight;

#pragma mark - 相机

/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *)image completion:(LTxCameraBOOLAndPHAssetCallbackBlock)completion;

/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *)url completion:(LTxCameraBOOLAndPHAssetCallbackBlock)completion;


#pragma mark - 相册

/**
 * 获取相册列表
 **/
+ (NSMutableArray*)getAllAlbumListWithOpinion:(BOOL)filterEmptyAlbum;


/**
 * 获取「相机胶卷」相册
 **/
+ (id)getCameraRollAlbum;

/**
 * 获取某个相册下的相片列表
 **/
+ (NSMutableArray*)getAssetsFromFetchResult:(PHFetchResult *)result;

/**
 * 获取相片
 **/
+ (void)getPhotoWithAsset:(PHAsset *)asset width:(CGFloat)width completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/**
 * 获取视频
 * presetName 默认：AVAssetExportPreset640x480
 **/
+ (void)exportVideoWithAsset:(PHAsset *)asset presetName:(NSString*)presetName completion:(LTxCameraPathAndStringCallbackBlock)completion;

/**
 * 获取图片
 **/
+ (void)exportImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality completion:(LTxCameraPathAndStringCallbackBlock)completion;

/**
 * 获取图片
 * 压缩质量
 **/
+ (void)exportImageWithAsset:(PHAsset *)asset compressionQuality:(CGFloat)compressionQuality completion:(LTxCameraImagePathAndStringCallbackBlock)completion;

/**
 * 获取视频播放源 AVPlayerItem
 **/
+ (void)getVideoPlayerItemWithAsset:(PHAsset *)asset completion:(LTxCameraAVPlayerItemAndDictionaryCallbackBlock)completion;

@end
