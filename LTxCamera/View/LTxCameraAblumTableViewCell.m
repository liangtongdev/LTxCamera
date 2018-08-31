//
//  LTxCameraAblumTableViewCell.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraAblumTableViewCell.h"

@interface LTxCameraAblumTableViewCell()

@property (nonatomic, strong) UIImageView* thumbImageView;
@property (nonatomic, strong) UILabel* nameL;

@end

@implementation LTxCameraAblumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self setupLTxCameraAblumContentView];
    return self;
}

-(void)setModel:(LTxCameraAlbumModel *)model{
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.nameL.attributedText = nameString;
    
    PHAsset* asset = [model.result lastObject];
    [LTxCameraUtil getPhotoWithAsset:asset width:80 progress:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    } completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbImageView.image = photo;
        });
    }];
}


-(void)setupLTxCameraAblumContentView{
    [self.contentView addSubview:self.thumbImageView];
    [self.contentView addSubview:self.nameL];
    
    
    NSLayoutConstraint* thumbLead = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.f constant:1];
    NSLayoutConstraint* thumbTop = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:1];
    NSLayoutConstraint* thumbWidth = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:80];
    NSLayoutConstraint* thumbBottom = [NSLayoutConstraint constraintWithItem:_thumbImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-1];
    
    NSLayoutConstraint* nameLead = [NSLayoutConstraint constraintWithItem:_nameL attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_thumbImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:6];
    NSLayoutConstraint* nameTrailing = [NSLayoutConstraint constraintWithItem:_nameL attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* nameCenterY = [NSLayoutConstraint constraintWithItem:_nameL attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_thumbImageView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0];
    
    
    [NSLayoutConstraint activateConstraints:@[thumbLead,thumbTop,thumbWidth,thumbBottom,nameLead,nameTrailing,nameCenterY]];
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

-(UILabel*)nameL{
    if(!_nameL){
        _nameL = [[UILabel alloc] init];
        _nameL.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameL;
}

@end
