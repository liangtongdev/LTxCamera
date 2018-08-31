//
//  LTxCameraPhotoPickerToolBar.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"


/**
 * 相片选择工具栏
 * 预览 | 原图 | 发送
 **/
@interface LTxCameraPhotoPickerToolBar : UIView

@property (nonatomic, assign) NSInteger selectCount;

//使用原图
@property (nonatomic, assign) BOOL useOriginalPhoto;
@property (nonatomic, assign) BOOL enablePreviewBtn;
@property (nonatomic, assign) BOOL enableOKBtn;

@property (nonatomic , copy) LTxCameraCallbackBlock previewCallback;
@property (nonatomic , copy) LTxCameraCallbackBlock originalPhotoCallback;
@property (nonatomic , copy) LTxCameraCallbackBlock okCallback;

@end
