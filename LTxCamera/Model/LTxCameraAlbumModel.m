//
//  LTxCameraAlbumModel.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraAlbumModel.h"

@implementation LTxCameraAlbumModel

-(void)setResult:(PHFetchResult *)result{
    _result = result;
    
    self.models = [LTxCameraUtil getAssetsFromFetchResult:result];
    self.count = [self.models count];
}

@end
