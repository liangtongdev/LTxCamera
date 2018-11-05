//
//  LTxCameraPhotoCollectionViewCell.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraPhotoCollectionViewCell.h"

@interface LTxCameraPhotoCollectionViewCell()

@property (nonatomic, strong) UIImageView* thumbImageView;
@property (nonatomic, strong) UIButton* selectBtn;
@property (nonatomic, strong) UIImageView* playImageView;

@end

@implementation LTxCameraPhotoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupLTxCameraAblumContentView];
        
        self.clipsToBounds = YES;
    }
    return self;
}


-(void)setupLTxCameraAblumContentView{
    [self.contentView addSubview:self.thumbImageView];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.playImageView];
    
    
    NSLayoutConstraint* thumbLead = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.f constant:1];
    NSLayoutConstraint* thumbTop = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:1];
    NSLayoutConstraint* thumbTrailing = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-1];
    NSLayoutConstraint* thumbBottom = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-1];
    [NSLayoutConstraint activateConstraints:@[thumbLead,thumbTop,thumbTrailing,thumbBottom]];
    
    
    NSLayoutConstraint* btnTop = [NSLayoutConstraint constraintWithItem:_selectBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:1];
    NSLayoutConstraint* btnTrailing = [NSLayoutConstraint constraintWithItem:_selectBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-1];
    NSLayoutConstraint* btnWidth = [NSLayoutConstraint constraintWithItem:_selectBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:40];
    NSLayoutConstraint* btnHeight = [NSLayoutConstraint constraintWithItem:_selectBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_selectBtn attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[btnTop,btnTrailing,btnWidth,btnHeight]];
    
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:_playImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:_playImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[centerX,centerY]];
}

#pragma mark - Getter
-(UIImageView*)thumbImageView{
    if(!_thumbImageView){
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _thumbImageView;
}

-(UIButton*)selectBtn{
    if(!_selectBtn){
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_selectBtn addTarget:self action:@selector(selectBtnPressed) forControlEvents:UIControlEventTouchDown];
    }
    return _selectBtn;
}

-(UIImageView*)playImageView{
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc] initWithImage:LTxCameraImageWithName(@"ic_video_play")];
        _playImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _playImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _playImageView;
}

#pragma mark - Setter

-(void)setModel:(LTxCameraAssetModel *)model{
    _model = model;
    if (model.isSelected) {
        [self.selectBtn setImage:LTxCameraImageWithName(@"ic_photo_selected") forState:UIControlStateNormal];
    }else{
        [self.selectBtn setImage:LTxCameraImageWithName(@"ic_photo_unselected") forState:UIControlStateNormal];
    }
    
    PHAsset* asset = model.asset;
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        self.playImageView.hidden = YES;
    }else{
        self.playImageView.hidden = NO;
    }
    
    if (model.thumbImage) {
        self.thumbImageView.image = model.thumbImage;
    }else{
        [LTxCameraUtil getPhotoWithAsset:asset width:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                model.thumbImage = photo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thumbImageView.image = photo;
                });
        }];
    }
    

    
    //获取原图的话，内存直接飙升，此处实现T.B.D。在点击原图的时候，再获取
    //同样，缩略图也不进行存储。
    
//    [LTxCameraUtil getPhotoWithAsset:asset width:0 progress:nil completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.model.originalImage = photo;
//        });
//    }];
    
}

#pragma mark - Action

-(void)selectBtnPressed{
    if (self.selectCallback){
        self.selectCallback();
    }
}
@end
