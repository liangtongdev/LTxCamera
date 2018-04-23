//
//  LTxCameraShootToolView.m
//  LTxCamera
//
//  Created by liangtong on 2018/3/5.
//  Copyright © 2018年 liangtong. All rights reserved.
//

#import "LTxCameraShootToolView.h"


@interface LTxCameraShootToolView()<CAAnimationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* bottomView;//拍照/视频控制区域底部(视频动画图层区)
@property (nonatomic, strong) UIView* topView;//拍照/视频控制区域顶部
@property (nonatomic, strong) CAShapeLayer* animateLayer;//视频动画
@property (nonatomic, strong) UIColor* circleProgressColor;//动画颜色

@property (nonatomic, strong) UIButton* dismissBtn;//消去
@property (nonatomic, strong) UIButton* cancelBtn;//取消
@property (nonatomic, strong) UIButton* doneBtn;//确定


@property (nonatomic, assign) BOOL stopRecord;

@end



@implementation LTxCameraShootToolView

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupComponents];
    }
    return self;
}

#pragma mark - Action
-(void)actionBtnPressed:(UIButton*)sender{
    if ([sender isEqual:_dismissBtn]) {
        if ([_delegate respondsToSelector:@selector(dismissCallback)]) {
            [_delegate dismissCallback];
        }
    }else if ([sender isEqual:_cancelBtn]){
        [self resetUI];
        if ([_delegate respondsToSelector:@selector(cancelCallback)]) {
            [_delegate cancelCallback];
        }
    }else if ([sender isEqual:_doneBtn]){
        if ([_delegate respondsToSelector:@selector(doneCallback)]) {
            [_delegate doneCallback];
        }
    }
}

#pragma mark - GestureRecognizer
- (void)tapAction:(UITapGestureRecognizer *)tap{
    [self stopAnimate];
    if ([_delegate respondsToSelector:@selector(takePhotoCallback)]) {
        [_delegate takePhotoCallback];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longG{
    switch (longG.state) {
        case UIGestureRecognizerStateBegan:
        {
            //此处不启动动画，由vc界面开始录制之后启动
            _stopRecord = NO;
            if ([_delegate respondsToSelector:@selector(startRecordVideoCallback)]) {
                [_delegate startRecordVideoCallback];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (_stopRecord) return;
            _stopRecord = YES;
            [self stopAnimate];
            if ([_delegate respondsToSelector:@selector(stopRecordVideoCallback)]) {
                [_delegate stopRecordVideoCallback];
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        return YES;
    }
    return NO;
}

#pragma mark - 动画
- (void)startAnimate{
    self.dismissBtn.hidden = YES;
    [UIView animateWithDuration:LTX_CAMERA_SHOOT_VIEW_ANIMATE_DURATION animations:^{
        self.bottomView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1);
        self.topView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 1);
    } completion:^(BOOL finished) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = self.maxRecordDuration;
        animation.delegate = self;
        [self.animateLayer addAnimation:animation forKey:nil];
        [self.bottomView.layer addSublayer:self.animateLayer];
    }];
}

- (void)stopAnimate{
    if (_animateLayer) {
        [self.animateLayer removeFromSuperlayer];
        [self.animateLayer removeAllAnimations];
    }
    
    self.bottomView.hidden = YES;
    self.topView.hidden = YES;
    self.dismissBtn.hidden = YES;
    
    self.bottomView.layer.transform = CATransform3DIdentity;
    self.topView.layer.transform = CATransform3DIdentity;
    
    [self showCancelDoneBtn];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_stopRecord) return;
    _stopRecord = YES;
    [self stopAnimate];
    if ([_delegate respondsToSelector:@selector(stopRecordVideoCallback)]) {
        [_delegate stopRecordVideoCallback];
    }
}

- (void)showCancelDoneBtn{
    [UIView animateWithDuration:LTX_CAMERA_SHOOT_VIEW_ANIMATE_DURATION animations:^{
        self.cancelBtn.hidden = NO;
        self.doneBtn.hidden = NO;
    }];
}

- (void)resetUI{
    if (_animateLayer.superlayer) {
        [self.animateLayer removeAllAnimations];
        [self.animateLayer removeFromSuperlayer];
    }
    self.dismissBtn.hidden = NO;
    self.bottomView.hidden = NO;
    self.topView.hidden = NO;
    self.cancelBtn.hidden = YES;
    self.doneBtn.hidden = YES;
    
}

#pragma mark - UI
/*设置界面的组件*/
-(void)setupComponents{
    
    _circleProgressColor = [UIColor greenColor];
    _maxRecordDuration = 10;
    
    [self addSubview:self.bottomView];
    [self addSubview:self.topView];
    [self addSubview:self.dismissBtn];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.doneBtn];
    
    //约束
    [self addConstraintsOnComponents];
    
    _bottomView.layer.cornerRadius = LTX_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH / 2;
    _bottomView.layer.masksToBounds = YES;
    _topView.layer.cornerRadius = LTX_CAMERA_SHOOT_VIEW_ACTION_FORGROUND_WIDTH / 2;
    _topView.layer.masksToBounds = YES;
//    _dismissBtn.layer.cornerRadius = LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH / 2;
//    _dismissBtn.layer.masksToBounds = YES;
    _cancelBtn.layer.cornerRadius = LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH / 2;
    _cancelBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH / 2;
    _doneBtn.layer.masksToBounds = YES;
    
}

#pragma mark - Components
-(void)addConstraintsOnComponents{
    //
    NSLayoutConstraint* bCenterX = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* bCenterY = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* bWidth = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH];
    NSLayoutConstraint* bHeight = [NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    
    NSLayoutConstraint* fCenterX = [NSLayoutConstraint constraintWithItem:_topView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* fCenterY = [NSLayoutConstraint constraintWithItem:_topView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* fWidth = [NSLayoutConstraint constraintWithItem:_topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_FORGROUND_WIDTH];
    NSLayoutConstraint* fHeight = [NSLayoutConstraint constraintWithItem:_topView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_topView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    
    NSLayoutConstraint* dCenterX = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeLeading multiplier:1.f constant:-LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_PADDING];
    NSLayoutConstraint* dCenterY = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* dWidth = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH];
    NSLayoutConstraint* dHeight = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    
    NSLayoutConstraint* cLeading = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* cTrailing = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* cTop = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* cBottom = [NSLayoutConstraint constraintWithItem:_cancelBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    
    NSLayoutConstraint* doneCenterX = [NSLayoutConstraint constraintWithItem:_doneBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_PADDING];
    NSLayoutConstraint* doneCenterY = [NSLayoutConstraint constraintWithItem:_doneBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* doneWidth = [NSLayoutConstraint constraintWithItem:_doneBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:LTX_CAMERA_SHOOT_VIEW_ACTION_BUTTON_WIDTH];
    NSLayoutConstraint* doneHeight = [NSLayoutConstraint constraintWithItem:_doneBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_doneBtn attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    
    [NSLayoutConstraint activateConstraints: @[bCenterX,bCenterY,bWidth,bHeight,
                                               fCenterX,fCenterY,fWidth,fHeight,
                                               dCenterX,dCenterY,dWidth,dHeight,
                                               cLeading,cTrailing,cTop,cBottom,
                                               doneCenterX,doneCenterY,doneWidth,doneHeight,
                                               ]];
}

#pragma mark - Setter
-(void)setAllowTakePhoto:(BOOL)allowTakePhoto{
    _allowTakePhoto = allowTakePhoto;
    if (allowTakePhoto) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.bottomView addGestureRecognizer:tap];
    }
}
- (void)setAllowRecordVideo:(BOOL)allowRecordVideo{
    _allowRecordVideo = allowRecordVideo;
    if (allowRecordVideo) {
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longG.minimumPressDuration = .3;
        longG.delegate = self;
        [self.bottomView addGestureRecognizer:longG];
    }
}

#pragma mark - Getter
-(UIView*)bottomView{
    if(!_bottomView){
        _bottomView = [[UIView alloc] init];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
    return _bottomView;
}
-(UIView*)topView{
    if(!_topView){
        _topView = [[UIView alloc] init];
        _topView.translatesAutoresizingMaskIntoConstraints = NO;
        _topView.userInteractionEnabled = NO;
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}
-(UIButton*)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_dismissBtn setImage:LTxImageWithName(@"ic_camera_action_dismiss") forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}
-(UIButton*)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _cancelBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [_cancelBtn setImage:LTxImageWithName(@"ic_camera_action_cancel") forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.hidden = YES;
    }
    return _cancelBtn;
}
-(UIButton*)doneBtn{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _doneBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [_doneBtn setImage:LTxImageWithName(@"ic_camera_action_done") forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.hidden = YES;
    }
    return _doneBtn;
}
- (CAShapeLayer *)animateLayer{
    if (!_animateLayer) {
        _animateLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, LTX_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH, LTX_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH) cornerRadius:LTX_CAMERA_SHOOT_VIEW_ACTION_BACKGROUND_WIDTH / 2];
        
        _animateLayer.strokeColor = self.circleProgressColor.CGColor;
        _animateLayer.fillColor = [UIColor clearColor].CGColor;
        _animateLayer.path = path.CGPath;
        _animateLayer.lineWidth = 8;
    }
    return _animateLayer;
}
@end
