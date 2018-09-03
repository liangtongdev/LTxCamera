//
//  LTxCameraVideoPlayerView.h
//  LTxCamera
//
//  Created by liangtong on 2018/3/7.
//  Copyright © 2018年 liangtong. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 视频播放画面
 * 视频循环播放，仿微信录视频
 **/
@interface LTxCameraVideoPlayerView : UIView

@property (nonatomic, strong) NSURL *videoUrl;//视频URL

/**
 * 开始播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 * 重置
 */
- (void)reset;

/**
 * 是否正在播放
 */
- (BOOL)isPlay;
@end
