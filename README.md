# LTxCamera
 + 拍照
 + 小视频
 + 扫码

![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/camera.png)


### Usage

####  Installation with CocoaPods

LTxCamera is available in CocoaPods, specify it in your *Podfile*:

```Objective-C
    pod ‘LTxCamera’
```


####  拍照/小视频


```Objective-C
    LTxCameraShootViewController* cameraShootVC = [[LTxCameraShootViewController alloc] init];
    cameraShootVC.allowTakePhoto = YES;//允许拍照
    cameraShootVC.allowRecordVideo = YES;//允许录制视频
    cameraShootVC.maxRecordDuration = 15;//录制视频最大时长
    cameraShootVC.shootDoneCallback = ^(UIImage* image, NSURL* videoPath, PHAsset *asset){
        
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraShootVC animated:NO completion:nil];
    });

```


## License

MIT License

Copyright (c) 2017 liangtong
