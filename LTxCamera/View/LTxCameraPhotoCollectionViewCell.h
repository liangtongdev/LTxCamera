//
//  LTxCameraPhotoCollectionViewCell.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"

/**
 * 相片
 **/
@interface LTxCameraPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) LTxCameraAssetModel* model;

@property (nonatomic, copy) LTxCameraCallbackBlock selectCallback;

@end
