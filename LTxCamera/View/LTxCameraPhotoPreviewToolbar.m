//
//  LTxCameraPhotoPreviewToolbar.m
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import "LTxCameraPhotoPreviewToolbar.h"
@interface LTxCameraPhotoPreviewToolbar()

@property (nonatomic, strong) UIButton* originalBtn;
@property (nonatomic, strong) UIButton* okBtn;

@end

#define DONE_BACKGROUND_COLOR [UIColor colorWithRed:(80/255.0) green:(180/255.0)  blue:0 alpha:1.0]
@implementation LTxCameraPhotoPreviewToolbar

- (instancetype)init{
    self = [super init];
    if (self) {
        [self addSubview:self.originalBtn];
        [self addSubview:self.okBtn];
        [self ltxCamera_addConstraintOnToobar];
    }
    return self;
}

/**
 * 约束
 **/
-(void)ltxCamera_addConstraintOnToobar{
    
    //原图 左侧
    NSLayoutConstraint* oriLeading = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:10];
    NSLayoutConstraint* oriTop = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* oriWidth = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:100];
    NSLayoutConstraint* oriBottom = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[oriLeading,oriTop,oriWidth,oriBottom]];
    
    //完成 右侧
    NSLayoutConstraint* okTrailing = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-15];
    NSLayoutConstraint* okTop = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:10];
    NSLayoutConstraint* okWidth = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:80];
    NSLayoutConstraint* okBottom = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:-10];
    [NSLayoutConstraint activateConstraints:@[okTrailing,okTop,okWidth,okBottom]];
}

#pragma mark - Getter

-(UIButton*)originalBtn{
    if(!_originalBtn){
        _originalBtn = [[UIButton alloc] init];
        _originalBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_originalBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_originalBtn setTitle:[NSString stringWithFormat:@"  %@",[NSBundle ltxCamera_localizedStringForKey:@"Full image"]] forState:UIControlStateNormal];
        [_originalBtn setImage:LTxImageWithName(@"ic_photo_original_sel") forState:UIControlStateSelected];
        [_originalBtn setImage:LTxImageWithName(@"ic_photo_original_def") forState:UIControlStateNormal];
        [_originalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_originalBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalBtn;
}
-(UIButton*)okBtn{
    if(!_okBtn){
        _okBtn = [[UIButton alloc] init];
        _okBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_okBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _okBtn.backgroundColor = DONE_BACKGROUND_COLOR;
        [_okBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _okBtn.layer.cornerRadius = 5.f;
        _okBtn.layer.masksToBounds = YES;
    }
    return _okBtn;
}

#pragma mark - Setter
-(void)setUseOriginalPhoto:(BOOL)useOriginalPhoto{
    _useOriginalPhoto = useOriginalPhoto;
    _originalBtn.selected = useOriginalPhoto;
}


-(void)setEnableOKBtn:(BOOL)enableOKBtn{
    _enableOKBtn = enableOKBtn;
    _okBtn.enabled = enableOKBtn;
    if(enableOKBtn){
        _okBtn.backgroundColor = DONE_BACKGROUND_COLOR;
    }else{
        _okBtn.backgroundColor = [DONE_BACKGROUND_COLOR colorWithAlphaComponent:0.8];
    }
}

-(void)setSelectCount:(NSInteger)selectCount{
    _selectCount = selectCount;
    if (selectCount < 1){
        self.enableOKBtn = NO;
        [self.okBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    }else{
        self.enableOKBtn = YES;
        [self.okBtn setTitle:[NSString stringWithFormat:@"%@(%td)",[NSBundle ltxCamera_localizedStringForKey:@"Done"],selectCount] forState:UIControlStateNormal];
    }
}


#pragma mark - Action

-(void)btnPressed:(UIButton*)btn{
    if ([btn isEqual:_originalBtn]){
        self.useOriginalPhoto = !self.useOriginalPhoto;
    }else if ([btn isEqual:_okBtn]){
        if(self.okCallback){
            self.okCallback();
        }
    }
}
@end
