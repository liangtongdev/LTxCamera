//
//  LTxCameraViewPreviewView.h
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LTxCameraUtil.h"

@interface LTxCameraViewPreviewView : UIView

@property (nonatomic, strong) AVPlayerItem *playerItem;

- (void)pause;

@end
