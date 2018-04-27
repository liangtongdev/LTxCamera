//
//  LTxCameraScanViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/4/26.
//

#import "LTxCameraScanViewController.h"

@interface LTxCameraScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) LTxCameraScanView* scanView;//扫码框
@property (nonatomic, assign) BOOL scanResult;
@property (nonatomic, strong) AVCaptureSession *session;/** 会话对象 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;/** 图层类 */
@end

@implementation LTxCameraScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCameraScanView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _scanResult = NO;
    [_scanView addTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        [self.session stopRunning];// 1、停止会话
        [self.previewLayer removeFromSuperlayer];// 2、删除预览图层
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {// 会频繁的扫描，调用代理方法
    if (_scanResult) {
        return;
    }
    if (metadataObjects.count > 0) {
        _scanResult = YES;
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        [self scanCompleteWithQRCode:obj.stringValue];
    }
}

#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if (brightnessValue < 0) {
        [self.scanView brightnessLight:YES];
    }else{
        [self.scanView brightnessLight:NO];
    }
}
#pragma mark - 相册
-(void)albumBtnAction{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init]; // 创建对象
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
    imagePicker.delegate = self; // 指定代理，因此我们要实现UIImagePickerControllerDelegate,  UINavigationControllerDelegate协议
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:imagePicker animated:YES completion:nil]; // 显示相册
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:image];
    }];
}

/** 从相册中识别二维码, 并进行界面跳转 */
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    BOOL find = false;
    for (CIQRCodeFeature *feature in features) {
        NSString *scannedResult = feature.messageString;
        [self scanCompleteWithQRCode:scannedResult];
        find = true;
        break;
    }
}


#pragma mark - Action
//扫描完成
-(void)scanCompleteWithQRCode:(NSString*)qrCode{
    NSLog(@"扫描的二维码：%@",qrCode);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _scanResult = NO;
    });
    if (_scanCallback) {
        _scanCallback(qrCode);
    }
}
- (void)willResignActive{
    if ([self.session isRunning]) {
        if(![self.navigationController popViewControllerAnimated:NO]){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma mark - UI
-(void)setupCameraScanView{
    _scanView = [[LTxCameraScanView alloc] init];
    _scanView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scanView];
    [self addConstraintsOnComponents];
    
    self.navigationItem.title = @"扫一扫";
    UIButton* albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 26)];
    [albumBtn addTarget:self action:@selector(albumBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    [albumBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
    [albumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:albumBtn];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];// 1、获取摄像设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];// 2、创建输入流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];// 3、创建输出流
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];// 4、设置代理 在主线程里刷新
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);// 设置扫描范围
    //光感传感器
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];// 5、初始化链接对象（会话对象）
    [_session setSessionPreset:AVCaptureSessionPreset1920x1080];// 高质量采集率
    [_session addInput:input];// 5.1 添加会话输入
    [_session addOutput:output];// 5.2 添加会话输出
    [_session addOutput:videoDataOutput];//光感传感器
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    //    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    // 9、启动会话
    [_session startRunning];
}
-(void)addConstraintsOnComponents{
    NSLayoutConstraint* scanLeadingConstraint = [NSLayoutConstraint constraintWithItem:_scanView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* scanTrailingConstraint = [NSLayoutConstraint constraintWithItem:_scanView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* scanTopConstraint = [NSLayoutConstraint constraintWithItem:_scanView attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1.f constant:0];
    NSLayoutConstraint* scanBottomConstraint = [NSLayoutConstraint constraintWithItem:_scanView attribute:NSLayoutAttributeBottomMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottomMargin multiplier:1.f constant:0];
    
    [NSLayoutConstraint activateConstraints:@[scanLeadingConstraint,scanTrailingConstraint,scanTopConstraint,scanBottomConstraint]];
}

@end
