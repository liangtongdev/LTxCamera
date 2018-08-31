//
//  NSBundle+LTxCamera.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "NSBundle+LTxCamera.h"
#import "LTxCameraUtil.h"


@implementation NSBundle (LTxCamera)

+ (NSBundle *)ltx_CameraBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[LTxCameraUtil class]];
    NSURL *url = [bundle URLForResource:@"LTxCamera" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key {
    return [self ltxCamera_localizedStringForKey:key value:@""];
}

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key value:(NSString *)value {
    return  [self ltxCamera_localizedStringForKey:key value:value preferredLanguage:nil];
}

+ (NSString *)ltxCamera_localizedStringForKey:(NSString *)key value:(NSString *)value preferredLanguage:(NSString*)preferredLanguage{
    if(!preferredLanguage || [preferredLanguage isEqualToString:@""]){
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    NSBundle* languageBundle = [NSBundle bundleWithPath:[[NSBundle ltx_CameraBundle] pathForResource:preferredLanguage ofType:@"lproj"]];
    
    NSString *value1 = [languageBundle localizedStringForKey:key value:value table:nil];
    return value1;
}
@end
