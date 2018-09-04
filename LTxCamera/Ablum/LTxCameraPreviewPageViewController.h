//
//  LTxCameraPreviewViewController.h
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import "LTxCameraPreviewViewController.h"
/***
 * 预览界面
 **/
@interface LTxCameraPreviewPageViewController : UIPageViewController

@property (nonatomic, strong) NSMutableArray* models;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger maxImagesCount;

@property (nonatomic, assign) BOOL useOriginalPhoto;

@property (nonatomic, copy) LTxCameraBOOLCallbackBlock okCallback;

@end
