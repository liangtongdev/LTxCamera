# LTxCamera
 + 相册
 + 拍照
 + 小视频
 + 扫码

## Installation with CocoaPods

LTxCamera is available in CocoaPods, specify it in your *Podfile*:


```Objective-C
   pod 'LTxCamera'
```

## Deployment
    9.0


## Demo

### Ablum


![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/ablum.png)

#### Usage

相片选择，设置最多选择数量

```Objective-C
        LTxCameraAblumViewController* ablumVC = [[LTxCameraAblumViewController alloc] init];
        ablumVC.photoPickerDelegate = self;
        ablumVC.maxImagesCount  =  9;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:ablumVC animated:YES completion:nil];
        });
```

回调包含图片、文件地址

```Objective-C
-(void)ltxCamera_photoPickerDidFinishPickingPhotos:(NSArray<UIImage *> *)photos paths:(NSArray<NSString*>*)paths sourceAssets:(NSArray *)assets{
    
}
```



### Camera


![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/camera.png)

#### Usage

仿微信的拍照/拍摄，设置小视频的格式、最长时间（秒）

```Objective-C
        LTxCameraShootViewController* cameraShootVC = [[LTxCameraShootViewController alloc] init];
        cameraShootVC.allowTakePhoto = YES;
        cameraShootVC.allowRecordVideo = YES;
        cameraShootVC.maxRecordDuration = 15;
        cameraShootVC.shootDoneCallback = ^(UIImage* image, NSURL* videoPath, PHAsset *asset){
            
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:cameraShootVC animated:NO completion:nil];
        });  
}
```


### Qrcode


![](https://github.com/liangtongdev/LTxCamera/blob/master/screenshots/qrcode.png)

#### Usage

二维码扫描，自动感应设备光线提示开灯

```Objective-C
        LTxCameraScanViewController* scanVC = [[LTxCameraScanViewController alloc] init];
        scanVC.scanCallback = ^(NSString *qrcode) {
            NSLog(@"qrcode : %@",qrcode);
        };
        [self.navigationController pushViewController:scanVC animated:NO];
}
```

二维码生成，颜色可定制

```Objective-C
        [LTxQRCodeGenerate fillQRImageWithImageView:_imageView qrString:@"Hello world!"];
}
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
