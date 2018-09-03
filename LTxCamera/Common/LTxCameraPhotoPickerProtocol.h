//
//  LTxCameraPhotoPickerProtocol.h
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import <Foundation/Foundation.h>


@protocol LTxCameraPhotoPickerDataSource <NSObject>

@optional
/**
 * 是否需要导出文档
 * 如果不实现，则表示导出
 **/
-(BOOL)ltx_cameraExportPickerFiles;

@end


@protocol LTxCameraPhotoPickerDelegate <NSObject>

@optional

/**
 * 点击完成时的回调
 **/
-(void)ltxCamera_photoPickerWillFinish;
/**
 * 完成后的回调
 **/
-(void)ltxCamera_photoPickerDidFinishPickingPhotos:(NSArray<UIImage *> *)photos thumbPhotos:(NSArray<UIImage *> *)thumbPhotos paths:(NSArray<NSString*>*)paths sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;

@end
