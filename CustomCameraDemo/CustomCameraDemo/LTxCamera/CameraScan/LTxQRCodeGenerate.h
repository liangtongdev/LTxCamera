//
//  LTxQRCodeGenerate.h
//  LTxCamera
//
//  Created by liangtong on 2018/4/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 * 二维码生成
 **/
@interface LTxQRCodeGenerate : NSObject

//填充以黑色的二维码
+(void)fillQRImageWithImageView:(UIImageView*)imageView qrString:(NSString*)qrString;

//获取二维码图片
+(UIImage*)createQRImageWithString:(NSString*)qrString size:(CGFloat)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
