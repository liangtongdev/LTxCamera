//
//  LTxSipprCameraShootViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/3/5.
//  Copyright © 2018年 liangtong. All rights reserved.
//

#import "LTxCameraShootViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "LTxCameraVideoPlayerView.h"
#import "LTxCameraUtil.h"
#define  LTX_CAMERA_TOOL_VIEW_HEIGH 160

@interface LTxCameraShootViewController ()<LTxCameraShootToolDelegate,AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityView;

//拍照录视频相关
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//预览图层
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;//照片输出流对象
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutPut;//视频输出流

//UI
@property (nonatomic, strong) LTxCameraShootToolView* toolView;//控制区
@property (nonatomic, strong) UIButton *toggleCameraBtn;//切换摄像头按钮
@property (nonatomic, strong) UIImageView *focusCursorImageView;//聚焦图


//Result
@property (nonatomic, strong) UIImageView *takedImageView;//拍照照片显示
@property (nonatomic, strong) UIImage *takedImage;//拍照的照片
@property (nonatomic, strong) NSURL *videoUrl;//录制视频保存的url
@property (nonatomic, strong) LTxCameraVideoPlayerView *playerView;//播放视频


@end

@implementation LTxCameraShootViewController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupComponents];
    [self setupCamera];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (!granted) {
                    [self onDismiss];
                }else{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
                }
            }];
        } else {
            [self onDismiss];
        }
    }];
    
    //暂停其他音乐，
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.session startRunning];
    [self setFocusCursorWithPoint:self.view.center];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.session) {
        [self.session stopRunning];
    }
}
- (void)dealloc{
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark LTxSipprCameraShootToolDelegate
/**
 * dismiss button pressed;
 **/
-(void)dismissCallback{
    [self onDismiss];
}

/**
 * cancel button pressed;
 **/
-(void)cancelCallback{
    [self.session startRunning];
    [self setFocusCursorWithPoint:self.view.center];
    self.takedImageView.hidden = YES;
    [self deleteVideo];
    self.takedImage = nil;
    self.videoUrl = nil;
}

/**
 * done button pressed;
 **/
-(void)doneCallback{
    //保存相册/视频
    __weak __typeof(self) weakSelf = self;
    if (self.takedImage) {
        [self showAnimatingActivityView];
        [LTxCameraUtil saveImageToAblum:self.takedImage completion:^(BOOL success, PHAsset *asset) {
            if (success) {
                [weakSelf hideAnimatingActivityView];
                [weakSelf onDismiss];
            }
            if (self.shootDoneCallback) {
                self.shootDoneCallback(self.takedImage, self.videoUrl,asset);
            }
        }];
    }
    if (self.videoUrl) {
        [self showAnimatingActivityView];
        [LTxCameraUtil saveVideoToAblum:self.videoUrl completion:^(BOOL success, PHAsset *asset) {
            if (success) {
                [weakSelf hideAnimatingActivityView];
                [weakSelf onDismiss];
            }
            if (self.shootDoneCallback) {
                self.shootDoneCallback(self.takedImage, self.videoUrl,asset);
            }
        }];
    }
}

/**
 * take photo callback;
 **/
-(void)takePhotoCallback{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    if (!_takedImageView) {
        _takedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _takedImageView.backgroundColor = [UIColor blackColor];
        _takedImageView.hidden = YES;
        _takedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view insertSubview:_takedImageView belowSubview:self.toolView];
    }
    __weak typeof(self) weakSelf = self;
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        AVCaptureDevicePosition position = self.videoInput.device.position;
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        if (position == AVCaptureDevicePositionFront) {
            NSLog(@"前置摄像头拍摄");
            weakSelf.takedImage = [UIImage imageWithCGImage:image.CGImage scale:1.f orientation:UIImageOrientationLeftMirrored];
            weakSelf.takedImageView.image = weakSelf.takedImage;
        }else{
            NSLog(@"后置摄像头拍摄");
            weakSelf.takedImage = image;
            weakSelf.takedImageView.image = image;
        }
        weakSelf.takedImageView.hidden = NO;
        [weakSelf.session stopRunning];
    }];
}

/**
 * start record video;
 **/
-(void)startRecordVideoCallback{
    AVCaptureConnection *movieConnection = [self.movieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
    movieConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [movieConnection setVideoScaleAndCropFactor:1.0];
    if (![self.movieFileOutPut isRecording]) {
        NSString *format = (_videoType == LTxSipprCameraShootExportVideoTypeMov ? @"mov" : @"mp4");
        NSString *exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[NSUUID UUID].UUIDString lowercaseString], format]];
        NSURL *url = [NSURL fileURLWithPath:exportFilePath];
        [self.movieFileOutPut startRecordingToOutputFileURL:url recordingDelegate:self];
    }
}
/**
 * stop record video;
 **/
-(void)stopRecordVideoCallback{
    [self.movieFileOutPut stopRecording];
    [self.session stopRunning];
    [self setVideoZoomFactor:1];
}



#pragma mark - Action

- (void)playVideo{
    if (!_playerView) {
        self.playerView = [[LTxCameraVideoPlayerView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:self.playerView belowSubview:self.toolView];
    }
    self.playerView.videoUrl = self.videoUrl;
    [self.playerView play];
}

- (void)deleteVideo{
    if (self.videoUrl) {
        [self.playerView reset];
        self.playerView.alpha = 0;
        [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
    }
}

- (void)willResignActive{
    if ([self.session isRunning]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
- (void)onDismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    [self.toolView startAnimate];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    if (CMTimeGetSeconds(output.recordedDuration) < 1) {
        //视频长度小于1s 允许拍照则拍照，不允许拍照，则保存小于1s的视频
        NSLog(@"视频长度小于1s，按拍照处理");
        [self takePhotoCallback];
        return;
    }
    
    self.videoUrl = outputFileURL;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playVideo];
    });
}


#pragma mark - 切换前后相机
//切换摄像头
- (void)btnToggleCameraAction{
    NSUInteger cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = self.videoInput.device.position;
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        } else {
            return;
        }
        
        if (newVideoInput) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                self.videoInput = newVideoInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"切换前后摄像头失败");
        }
    }
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - 点击屏幕设置聚焦点
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.session.isRunning) return;
    
    CGPoint point = [touches.anyObject locationInView:self.view];
    if (point.y > CGRectGetHeight(self.view.bounds) - LTX_CAMERA_TOOL_VIEW_HEIGH) {
        return;
    }
    [self setFocusCursorWithPoint:point];
}

//设置聚焦光标位置
- (void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursorImageView.center = point;
    self.focusCursorImageView.alpha = 1;
    self.focusCursorImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:1.f animations:^{
        self.focusCursorImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImageView.alpha=0;
    }];
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

//设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    AVCaptureDevice * captureDevice = [self.videoInput device];
    NSError * error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if (![captureDevice lockForConfiguration:&error]) {
        return;
    }
    //聚焦模式
    if ([captureDevice isFocusModeSupported:focusMode]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    //聚焦点
    if ([captureDevice isFocusPointOfInterestSupported]) {
        [captureDevice setFocusPointOfInterest:point];
    }
    [captureDevice unlockForConfiguration];
}
- (void)setVideoZoomFactor:(CGFloat)zoomFactor{
    AVCaptureDevice * captureDevice = [self.videoInput device];
    NSError *error = nil;
    [captureDevice lockForConfiguration:&error];
    if (error) return;
    captureDevice.videoZoomFactor = zoomFactor;
    [captureDevice unlockForConfiguration];
}

#pragma mark - 初始化
-(void)setupComponents{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.toolView];
    [self.view addSubview:self.toggleCameraBtn];
    [self.view addSubview:self.activityView];
    [self addConstraintsOnComponents];
    
    
    _toolView.allowTakePhoto = self.allowTakePhoto;
    _toolView.allowRecordVideo = self.allowRecordVideo;
    _toolView.maxRecordDuration = self.maxRecordDuration;
    
    _focusCursorImageView = [[UIImageView alloc] initWithImage:LTxImageWithName(@"ic_camera_focus")];
    [self.view addSubview:_focusCursorImageView];
}

-(void)addConstraintsOnComponents{
    NSLayoutConstraint* tLeading = [NSLayoutConstraint constraintWithItem:_toolView attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeadingMargin multiplier:1.f constant:-20];
    NSLayoutConstraint* tTrailing = [NSLayoutConstraint constraintWithItem:_toolView attribute:NSLayoutAttributeTrailingMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1.f constant:20];
    NSLayoutConstraint* tHeight = [NSLayoutConstraint constraintWithItem:_toolView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_TOOL_VIEW_HEIGH];
    NSLayoutConstraint* tBottom = [NSLayoutConstraint constraintWithItem:_toolView attribute:NSLayoutAttributeBottomMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottomMargin multiplier:1.f constant:0];
    
    NSLayoutConstraint* bTop = [NSLayoutConstraint constraintWithItem:_toggleCameraBtn attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1.f constant:20];
    NSLayoutConstraint* bTrailing = [NSLayoutConstraint constraintWithItem:_toggleCameraBtn attribute:NSLayoutAttributeTrailingMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1.f constant:-10];
    NSLayoutConstraint* bWidth = [NSLayoutConstraint constraintWithItem:_toggleCameraBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH];
    NSLayoutConstraint* bHeight = [NSLayoutConstraint constraintWithItem:_toggleCameraBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_toggleCameraBtn attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    
    NSLayoutConstraint* aCenterX = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* aCenterY = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* aWidth = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:100.f];
    NSLayoutConstraint* aHeight = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f];
    
    _activityView.backgroundColor = [UIColor lightGrayColor];
    
    [NSLayoutConstraint activateConstraints: @[tLeading,tTrailing,tHeight,tBottom,
                                               bTop,bTrailing,bWidth,bHeight,
                                               aCenterX,aCenterY,aWidth,aHeight
                                               ]];
}

-(LTxCameraShootToolView*)toolView{
    if (!_toolView) {
        _toolView = [[LTxCameraShootToolView alloc] init];
        _toolView.backgroundColor = [UIColor clearColor];
        _toolView.delegate = self;
        _toolView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _toolView;
}
-(UIButton*)toggleCameraBtn{
    if (!_toggleCameraBtn) {
        _toggleCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleCameraBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_toggleCameraBtn setImage:LTxImageWithName(@"ic_camera_action_toggle") forState:UIControlStateNormal];
        [_toggleCameraBtn addTarget:self action:@selector(btnToggleCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toggleCameraBtn;
}
-(UIActivityIndicatorView*)activityView{
    if(!_activityView){
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityView.layer.cornerRadius = 8.f;
        _activityView.clipsToBounds = YES;
    }
    return _activityView;
}

- (void)setupCamera{
    self.session = [[AVCaptureSession alloc] init];
    
    //相机画面输入流
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    
    //照片输出流
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    NSDictionary *dicOutputSetting = [NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    [self.imageOutPut setOutputSettings:dicOutputSetting];
    
    //音频输入流
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:nil];
    
    //视频输出流
    //设置视频格式
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    self.movieFileOutPut = [[AVCaptureMovieFileOutput alloc] init];
    
    //将视频及音频输入流添加到session
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    }
    //将输出流添加到session
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    if ([self.session canAddOutput:self.movieFileOutPut]) {
        [self.session addOutput:self.movieFileOutPut];
    }
    //预览层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.view.layer setMasksToBounds:YES];
    _previewLayer.frame = self.view.layer.bounds;
    
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

#pragma mark - ActivityView
-(void)showAnimatingActivityView{
    [self.view bringSubviewToFront:_activityView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView startAnimating];
    });
}
-(void)showAnimatingActivityViewWithStyle:(UIActivityIndicatorViewStyle)style{
    _activityView.activityIndicatorViewStyle = style;
    [self.view bringSubviewToFront:_activityView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView startAnimating];
    });
}
-(void)hideAnimatingActivityView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityView stopAnimating];
    });
}


@end
