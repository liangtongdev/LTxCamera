//
//  LTxCameraScanView.m
//  LTxCamera
//
//  Created by liangtong on 2018/4/24.
//

#import "LTxCameraScanView.h"
@interface LTxCameraScanView()
@property (nonatomic, strong) UIButton* openFlashLightBtn;
@property (nonatomic, strong) UILabel* tipL;
@property (nonatomic, assign) BOOL openState;//用户打开灯光

/** 扫描动画线(冲击波) */
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) NSLayoutConstraint* animateTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint* animateHeightConstraint;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger animateFlag;
@end
@implementation LTxCameraScanView

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupComponents];
    }
    return self;
}
/*设置界面的组件*/
-(void)setupComponents{
    
    self.borderWidth = 1.f;
    self.borderColor = [UIColor whiteColor];
    self.cornerColor = [UIColor greenColor];
    self.cornerWidth = 3.f;
    self.cornerLength = 26.f;
    
    self.scanAnimateImageHeight = 10.f;
    
    self.backgroundColor = [UIColor clearColor];
    
    //扫描边框 ： 固定大小，居中显示
    [self addConstraintsOnComponents];
    _animateFlag = 0;
}


-(void)dealloc{
    [self removeTimer];
    [self.animationImageView removeFromSuperview];
    self.animationImageView = nil;
}


#pragma mark - Timer

-(void)addTimer{
    // 添加定时器
    self.timer =[NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(animationLineAction) userInfo:nil repeats:YES];
}
-(void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}


- (void)animationLineAction {
    ++_animateFlag;
    NSInteger constant = _animateFlag * 3;
    if (constant > LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE - self.scanAnimateImageHeight) {
        _animateFlag = 0;
        constant = 0;
    }
    CGFloat top = self.bounds.size.height / 2 - LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.animateTopConstraint.constant = constant + top;
        [self layoutIfNeeded];
    });
}

-(void)brightnessLight:(BOOL)isNight{
    
    if (isNight) {
        if (_openState) {
            [_openFlashLightBtn setImage:LTxCameraImageWithName(@"ic_flash_light_close") forState:UIControlStateNormal];
        }else{
            [_openFlashLightBtn setImage:LTxCameraImageWithName(@"ic_flash_light_open") forState:UIControlStateNormal];
        }
        _openFlashLightBtn.hidden = NO;
    }else{
        if (_openState) {
            [_openFlashLightBtn setImage:LTxCameraImageWithName(@"ic_flash_light_close") forState:UIControlStateNormal];
            _openFlashLightBtn.hidden = NO;
        }else{
            _openFlashLightBtn.hidden = YES;
        }
    }
    [_openFlashLightBtn setNeedsDisplay];
}

/*控制灯光*/
-(void)openFlashLight:(BOOL)open{
    if (open) {
        [LTxCameraUtil openFlashlight];
    }else{
        [LTxCameraUtil closeFlashlight];
    }
    _openState = open;
}

-(void)openFlashLightAction:(UIButton*)btn{
    if (_openState) {
        [self openFlashLight:NO];
    }else{
        [self openFlashLight:YES];
    }
    
}

#pragma mark - Components
-(void)addConstraintsOnComponents{
    //animateImageView
    NSLayoutConstraint* aCenterX = [NSLayoutConstraint constraintWithItem:self.animationImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* aWidth = [NSLayoutConstraint constraintWithItem:self.animationImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE];
    _animateHeightConstraint = [NSLayoutConstraint constraintWithItem:self.animationImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.scanAnimateImageHeight];
    _animateTopConstraint = [NSLayoutConstraint constraintWithItem:self.animationImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];

    //OpenFlashLightBtn
    NSLayoutConstraint* bCenterX = [NSLayoutConstraint constraintWithItem:self.openFlashLightBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* bCenterY = [NSLayoutConstraint constraintWithItem:self.openFlashLightBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:80];

    //TipLabel
    NSLayoutConstraint* tCenterX = [NSLayoutConstraint constraintWithItem:self.tipL attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* tCenterY = [NSLayoutConstraint constraintWithItem:self.tipL attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2 + 30];
    [NSLayoutConstraint activateConstraints: @[aCenterX,aWidth,_animateHeightConstraint,_animateTopConstraint,
                                               bCenterX,bCenterY,tCenterX,tCenterY
                                               ]];
}


#pragma mark - Getter 方法

-(UIImageView*)animationImageView{
    if (!_animationImageView) {
        _animationImageView = [[UIImageView alloc] init];
        _animationImageView.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage* image = LTxCameraImageWithName(@"ic_camera_qrcode_scan_animate_line");
        _animationImageView.image = image;
        [self addSubview:_animationImageView];
    }
    return _animationImageView;
}

-(UIButton*)openFlashLightBtn{
    if (!_openFlashLightBtn) {
        _openFlashLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _openFlashLightBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_openFlashLightBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_openFlashLightBtn setBackgroundColor:[UIColor clearColor]];
        [_openFlashLightBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_openFlashLightBtn addTarget:self action:@selector(openFlashLightAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_openFlashLightBtn];
    }
    return _openFlashLightBtn;
}

-(UILabel*)tipL{
    if (!_tipL) {
        _tipL = [[UILabel alloc] init];
        _tipL.translatesAutoresizingMaskIntoConstraints = NO;
        _tipL.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _tipL.font = [UIFont boldSystemFontOfSize:16];
        _tipL.textAlignment = NSTextAlignmentCenter;
        _tipL.text = @"将二维码/条码放入框内";
        [self addSubview:_tipL];
    }
    return _tipL;
}

#pragma mark - Setter
-(void)setScanAnimateImage:(UIImage *)scanAnimateImage{
    _scanAnimateImage = scanAnimateImage;
    if (scanAnimateImage) {
        _animationImageView.image = scanAnimateImage;
    }
}

-(void)setScanAnimateImageHeight:(CGFloat)scanAnimateImageHeight{
    _scanAnimateImageHeight = scanAnimateImageHeight;
    if (scanAnimateImageHeight > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animateHeightConstraint.constant = scanAnimateImageHeight;
            [self.animationImageView layoutIfNeeded];
        });
    }
}


/**
 * 画图
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //根据中心点，确定上下左右四个位置
    
    CGFloat left = rect.size.width / 2 - LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2;
    CGFloat top = rect.size.height / 2 - LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2;
    CGFloat bottom = rect.size.height / 2 + LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2;
    CGFloat right = rect.size.width / 2 + LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE / 2;
    
    /// 空白区域设置
    [[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
    UIRectFill(rect);
    // 获取上下文，并设置混合模式 -> kCGBlendModeDestinationOut
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    // 设置空白区
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(left, top, LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE, LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE)];
    [bezierPath fill];
    // 执行混合模式
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    /// 边框设置
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(left, top, LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE, LTX_CAMERA_QRCODE_SCAN_VIEW_SIZE)];
    borderPath.lineCapStyle = kCGLineCapButt;
    borderPath.lineWidth = self.borderWidth;
    [self.borderColor set];
    [borderPath stroke];
    
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    cornerPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    //左上角
    [cornerPath moveToPoint:CGPointMake(left, top + self.cornerLength)];
    [cornerPath addLineToPoint:CGPointMake(left, top)];
    [cornerPath addLineToPoint:CGPointMake(left + self.cornerLength, top)];
    [cornerPath stroke];
    //右上角
    [cornerPath moveToPoint:CGPointMake(right - self.cornerLength, top)];
    [cornerPath addLineToPoint:CGPointMake(right, top)];
    [cornerPath addLineToPoint:CGPointMake(right, top + self.cornerLength)];
    [cornerPath stroke];
    //右下角
    [cornerPath moveToPoint:CGPointMake(right, bottom - self.cornerLength)];
    [cornerPath addLineToPoint:CGPointMake(right, bottom)];
    [cornerPath addLineToPoint:CGPointMake(right - self.cornerLength, bottom)];
    [cornerPath stroke];
    //左下角
    [cornerPath moveToPoint:CGPointMake(left + self.cornerLength, bottom)];
    [cornerPath addLineToPoint:CGPointMake(left, bottom)];
    [cornerPath addLineToPoint:CGPointMake(left, bottom - self.cornerLength)];
    [cornerPath stroke];
}
@end
