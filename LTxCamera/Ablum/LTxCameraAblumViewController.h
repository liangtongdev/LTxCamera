//
//  LTxCameraAblumViewController.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"
/**
 * 相册NavigationController
 **/
@interface LTxCameraAblumViewController : UINavigationController

//协议
@property (nonatomic, weak) id<LTxCameraPhotoPickerDelegate> photoPickerDelegate;
@property (nonatomic, weak) id<LTxCameraPhotoPickerDataSource> photoPickerDataSource;

@property (nonatomic, assign) NSInteger maxImagesCount;

@end

/**
 * 相册的跟视图
 * 没有权限的情况下，展示一句提示信息
 * 有权限的情况下，展示相册列表
 **/
@interface LTxCameraAblumTableViewController : UITableViewController//协议
@property (nonatomic, weak) id<LTxCameraPhotoPickerDelegate> photoPickerDelegate;
@property (nonatomic, weak) id<LTxCameraPhotoPickerDataSource> photoPickerDataSource;
@property (nonatomic, assign) NSInteger maxImagesCount;
@end
