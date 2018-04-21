//
//  LTxSipprCameraShootView.h
//  LTxCamera
//
//  Created by liangtong on 2018/3/5.
//  Copyright © 2018年 liangtong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTxCameraUtil.h"
#define LTXSIPPR_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH 75
#define LTXSIPPR_CAMERA_SHOOT_VIEW_ACTION_FORGROUND_WIDTH  (LTXSIPPR_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH - 20)
#define LTXSIPPR_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH 70
#define LTXSIPPR_CAMERA_SHOOT_VIEW_ACTION_BUTTON_PADDING 40
#define LTXSIPPR_CAMERA_SHOOT_VIEW_ANIMATE_DURATION .1

@protocol LTxCameraShootToolDelegate <NSObject>

@required
/**
 * dismiss button pressed;
 **/
-(void)dismissCallback;

/**
 * cancel button pressed;
 **/
-(void)cancelCallback;

/**
 * done button pressed;
 **/
-(void)doneCallback;

@optional
/**
 * take photo callback;
 **/
-(void)takePhotoCallback;

/**
 * start record video;
 **/
-(void)startRecordVideoCallback;
/**
 * stop record video;
 **/
-(void)stopRecordVideoCallback;

@end

/**
 * 自定义照片/视频拍摄工具栏
 * 可以拍摄照片，录制视频区
 * dismiss按钮
 * 取消和确定按钮
 **/
@interface LTxCameraShootToolView : UIView

@property (nonatomic, weak) id  <LTxCameraShootToolDelegate> delegate;
@property (nonatomic, assign) BOOL allowTakePhoto;
@property (nonatomic, assign) BOOL allowRecordVideo;
@property (nonatomic, assign) NSInteger maxRecordDuration;//最大录制时常

- (void)startAnimate;

@end
