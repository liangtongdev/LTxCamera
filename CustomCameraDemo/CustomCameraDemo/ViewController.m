//
//  ViewController.m
//  CustomCameraDemo
//
//  Created by liangtong on 2018/4/21.
//

#import "ViewController.h"
#import "LTxCameraShootViewController.h"
#import "LTxCameraScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"LTxCamera";
}

- (IBAction)showCameraAction:(UIButton *)sender {
    LTxCameraShootViewController* cameraShootVC = [[LTxCameraShootViewController alloc] init];
    cameraShootVC.allowTakePhoto = YES;
    cameraShootVC.allowRecordVideo = YES;
    cameraShootVC.maxRecordDuration = 15;
    cameraShootVC.shootDoneCallback = ^(UIImage* image, NSURL* videoPath, PHAsset *asset){
        
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraShootVC animated:NO completion:nil];
    });
}

- (IBAction)scanCodeAction:(UIButton *)sender {
    LTxCameraScanViewController* scanVC = [[LTxCameraScanViewController alloc] init];
    scanVC.scanCallback = ^(NSString *qrcode) {
        NSLog(@"qrcode : %@",qrcode);
    };
    [self.navigationController pushViewController:scanVC animated:NO];
}


@end
