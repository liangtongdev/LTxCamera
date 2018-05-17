# LTxCamera
 + 拍照
 + 小视频
 + 扫码

![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/camera.png)

![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/qrcode.png)

### Usage

####  Installation with CocoaPods

LTxCamera is available in CocoaPods, specify it in your *Podfile*:


```Objective-C
    pod ‘LTxCamera’
```


####  photo-shooting and video-recording


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

####  QRcode-scaning


```Objective-C
    LTxCameraScanViewController* scanVC = [[LTxCameraScanViewController alloc] init];
    scanVC.scanCallback = ^(NSString *qrcode) {
        NSLog(@"qrcode : %@",qrcode);
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:scanVC animated:NO];
    });

```

####  QRcode-generating


```Objective-C
    [LTxQRCodeGenerate fillQRImageWithImageView:_imageView qrString:@"Hello world!"];
```

## License

MIT License

Copyright (c) 2017 liangtong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
