//
//  LTxCameraWaitingView.m
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import "LTxCameraWaitingView.h"
@interface LTxCameraWaitingView()
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@end
@implementation LTxCameraWaitingView

-(instancetype)init{
    self = [super init];
    if (self) {
        [self ltxCamera_setupWaitingView];
    }
    return self;
}

/*
 * 初始化
 ***/
-(void)ltxCamera_setupWaitingView{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    _activityView.layer.cornerRadius = 8.f;
    _activityView.clipsToBounds = YES;
    _activityView.hidesWhenStopped = YES;
    
    [self addSubview:_activityView];
    
    NSLayoutConstraint* aCenterX = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* aCenterY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    NSLayoutConstraint* aWidth = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:100.f];
    NSLayoutConstraint* aHeight = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_activityView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f];
    
    _activityView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    
    [NSLayoutConstraint activateConstraints: @[aCenterX,aCenterY,aWidth,aHeight]];
}

-(void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alpha = 1;
        [self.activityView startAnimating];
    });
}

-(void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alpha = 0;
        [self.activityView stopAnimating];
    });
}

@end
