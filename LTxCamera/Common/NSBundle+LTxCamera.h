//
//  NSBundle+LTxCamera.h
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import <Foundation/Foundation.h>

@interface NSBundle (LTxCamera)

+ (NSBundle *)ltx_CameraBundle;

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key;

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key value:(NSString *)value;

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key value:(NSString *)value preferredLanguage:(NSString*)preferredLanguage;
@end
