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
 * 压缩质量
 * 默认情况下，为1.0，低质量为0.8
 ***/
-(CGFloat)ltxCamera_exportImageCompressionQuality;

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
-(void)ltxCamera_photoPickerDidFinishPickingPhotos:(NSArray<UIImage *> *)photos paths:(NSArray<NSString*>*)paths sourceAssets:(NSArray *)assets ;

@end
