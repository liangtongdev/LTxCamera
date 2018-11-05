//
//  LTxCameraViewPreviewView.m
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import "LTxCameraViewPreviewView.h"
@interface LTxCameraViewPreviewView()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIImageView* playPauseIV;

@end
@implementation LTxCameraViewPreviewView

- (void)dealloc{
    [self removeObserver];
    [_player pause];
    _player = nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
    self.playerLayer = [[AVPlayerLayer alloc] init];
    
    _playPauseIV = [[UIImageView alloc] initWithImage:LTxCameraImageWithName(@"ic_video_play")];
    _playPauseIV.frame = CGRectMake(0, 0, 60, 60);
    _playPauseIV.contentMode = UIViewContentModeScaleAspectFill;

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}

-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    _playerItem = playerItem;

    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self addSubview:_playPauseIV];
    _playPauseIV.center = self.center;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1;
            }];
        }
    }
}

-(void)tapAction{
    if ([self isPlay]) {
        [self pause];
        _playPauseIV.hidden = NO;
    }else{
        [self play];
        _playPauseIV.hidden = YES;
    }
}

- (void)playFinished{
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (void)play{
    [_player play];
}

- (void)pause{
    [_player pause];
}

- (void)reset{
    [self removeObserver];
    [_player pause];
    _player = nil;
}

- (BOOL)isPlay{
    return _player && _player.rate > 0;
}

- (void)removeObserver{
    [_player removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
