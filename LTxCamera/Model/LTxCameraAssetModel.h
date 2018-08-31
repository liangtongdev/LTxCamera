//
//  LTxCameraAssetModel.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LTxCameraAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;

@end
