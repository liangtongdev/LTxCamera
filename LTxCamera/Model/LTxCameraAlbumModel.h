//
//  LTxCameraAlbumModel.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/***
 * 相册
 * 包含缩略图、名称及包含相片的个数
 **/
@interface LTxCameraAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) NSMutableArray *models;
@end
