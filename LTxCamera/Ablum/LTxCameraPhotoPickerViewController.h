//
//  LTxCameraPhotoPickerViewController.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"
#import "LTxCameraPhotoPickerProtocol.h"
/**
 * 相片选择界面
 **/

@interface LTxCameraPhotoPickerViewController : UIViewController


//协议
@property (nonatomic, weak) id<LTxCameraPhotoPickerDelegate> photoPickerDelegate;
@property (nonatomic, weak) id<LTxCameraPhotoPickerDataSource> photoPickerDataSource;
@property (nonatomic, assign) NSInteger maxImagesCount;

//相册名称
@property (nonatomic, strong) LTxCameraAlbumModel *model;

@end
