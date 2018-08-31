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
        [_selectBtn addTarget:self action:@selector(selectBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

#pragma mark - Setter

-(void)setModel:(LTxCameraAssetModel *)model{
    _model = model;
    if (model.isSelected) {
        [self.selectBtn setImage:LTxImageWithName(@"ic_photo_selected") forState:UIControlStateNormal];
    }else{
        [self.selectBtn setImage:LTxImageWithName(@"ic_photo_unselected") forState:UIControlStateNormal];
    }
    
    PHAsset* asset = model.asset;
    [LTxCameraUtil getPhotoWithAsset:asset width:80 progress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    } completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbImageView.image = photo;
        });
    }];
    
}

#pragma mark - Action

-(void)selectBtnPressed{
    if (self.selectCallback){
        self.selectCallback();
    }
}
@end
