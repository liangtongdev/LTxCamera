//
//  LTxCameraPhotoPreviewToolbar.h
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"

/**
 * 图片预览工具栏
 * 原图 | 完成
 ***/
@interface LTxCameraPhotoPreviewToolbar : UIView
@property (nonatomic, assign) NSInteger selectCount;
@property (nonatomic, assign) BOOL useOriginalPhoto;
@property (nonatomic, assign) BOOL enableOKBtn;

@property (nonatomic , copy) LTxCameraCallbackBlock okCallback;
@end
