//
//  LTxCameraPreviewViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import "LTxCameraPreviewViewController.h"
#import "LTxCameraViewPreviewView.h"

@interface LTxCameraPreviewViewController ()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) LTxCameraViewPreviewView* playerView;

@end

@implementation LTxCameraPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self ltxCamera_setupPreviewView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.playerView){
        [self.playerView pause];
    }
}

-(void)dealloc{
    [self.imageView removeFromSuperview];
    [self.playerView pause];
    [self.playerView removeFromSuperview];
    self.imageView = nil;
    self.playerView = nil;
}

#pragma mark - Setup
-(void)ltxCamera_setupPreviewView{
    if (_model.asset.mediaType == PHAssetMediaTypeImage) {
        [self.view addSubview:self.imageView];
        [self ltxCamrea_constraintSubview:_imageView];
        
        
        self.imageView.image = _model.thumbImage;
        [LTxCameraUtil getPhotoWithAsset:_model.asset width:0 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (!isDegraded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = photo;
                });
            }
        }];
        
    }else{
        [self.view addSubview:self.playerView];
        [self ltxCamrea_constraintSubview:_playerView];
        

        [LTxCameraUtil getVideoPlayerItemWithAsset:_model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.playerView.playerItem = item;
            });
        }];
    }
}

-(void)ltxCamrea_constraintSubview:(UIView*)subView{
    NSLayoutConstraint* waitingLead = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* waitingTop = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* waitingTrailing = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* waitingBottom = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:-50];
    [NSLayoutConstraint activateConstraints:@[waitingLead,waitingTop,waitingTrailing,waitingBottom]];
}




#pragma mark - Getter
-(UIImageView*)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

-(LTxCameraViewPreviewView*)playerView{
    if (!_playerView) {
        _playerView = [[LTxCameraViewPreviewView alloc] init];
        _playerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _playerView;
}



@end
