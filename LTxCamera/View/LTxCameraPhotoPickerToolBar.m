//
//  LTxCameraPhotoPickerToolBar.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraPhotoPickerToolBar.h"

@interface LTxCameraPhotoPickerToolBar()

@property (nonatomic, strong) UIButton* previewBtn;
@property (nonatomic, strong) UIButton* originalBtn;
@property (nonatomic, strong) UIButton* okBtn;

@end

#define DONE_BACKGROUND_COLOR [UIColor colorWithRed:(80/255.0) green:(180/255.0)  blue:0 alpha:1.0]

@implementation LTxCameraPhotoPickerToolBar


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (!_previewBtn) {
        [self addSubview:self.previewBtn];
        [self addSubview:self.originalBtn];
        [self addSubview:self.okBtn];
        [self ltxCamera_addConstraintOnToobar];
    }
    
}

/**
 * 约束
 **/
-(void)ltxCamera_addConstraintOnToobar{
    //preview 左侧
    NSLayoutConstraint* preLeading = [NSLayoutConstraint constraintWithItem:_previewBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* preTop = [NSLayoutConstraint constraintWithItem:_previewBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* preWidth = [NSLayoutConstraint constraintWithItem:_previewBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:80];
    NSLayoutConstraint* preBottom = [NSLayoutConstraint constraintWithItem:_previewBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[preLeading,preTop,preWidth,preBottom]];

    //原图 居中
    NSLayoutConstraint* oriCenterX = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* oriTop = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* oriWidth = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:80];
    NSLayoutConstraint* oriBottom = [NSLayoutConstraint constraintWithItem:_originalBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[oriCenterX,oriTop,oriWidth,oriBottom]];
    
    //完成 右侧
    NSLayoutConstraint* okTrailing = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-15];
    NSLayoutConstraint* okTop = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:10];
    NSLayoutConstraint* okWidth = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:80];
    NSLayoutConstraint* okBottom = [NSLayoutConstraint constraintWithItem:_okBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:-10];
    [NSLayoutConstraint activateConstraints:@[okTrailing,okTop,okWidth,okBottom]];
}

#pragma mark - Getter

-(UIButton*)previewBtn{
    if(!_previewBtn){
        _previewBtn = [[UIButton alloc] init];
        _previewBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_previewBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_previewBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Preview"] forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_previewBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewBtn;
}
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

-(void)setEnablePreviewBtn:(BOOL)enablePreviewBtn{
    _enablePreviewBtn = enablePreviewBtn;
    _previewBtn.enabled = enablePreviewBtn;
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
        self.enablePreviewBtn = NO;
        self.enableOKBtn = NO;
        [_okBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    }else{
        self.enablePreviewBtn = YES;
        self.enableOKBtn = YES;
        [_okBtn setTitle:[NSString stringWithFormat:@"%@(%td)",[NSBundle ltxCamera_localizedStringForKey:@"Done"],selectCount] forState:UIControlStateNormal];
    }
}


#pragma mark - Action

-(void)btnPressed:(UIButton*)btn{
    if ([btn isEqual:_previewBtn]){
        if(self.previewCallback){
            self.previewCallback();
        }
    }else if ([btn isEqual:_originalBtn]){
        self.useOriginalPhoto = !self.useOriginalPhoto;
        if(self.originalPhotoCallback){
            self.originalPhotoCallback();
        }
    }else if ([btn isEqual:_okBtn]){
        if(self.okCallback){
            self.okCallback();
        }
    }
}
@end
