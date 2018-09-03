//
//  LTxCameraAlbumModel.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraAlbumModel.h"
#import "LTxCameraAssetModel.h"
@implementation LTxCameraAlbumModel

-(void)setResult:(PHFetchResult *)result{
    _result = result;

    NSMutableArray *photoArr = [[NSMutableArray alloc] init];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        LTxCameraAssetModel* assetModel = [[LTxCameraAssetModel alloc] init];
        assetModel.asset = asset;
        [photoArr addObject:assetModel];
    }];
    self.models = photoArr;
    
    self.count = [self.models count];
}

@end
