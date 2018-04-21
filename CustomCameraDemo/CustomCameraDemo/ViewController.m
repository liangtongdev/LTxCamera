//
//  ViewController.m
//  CustomCameraDemo
//
//  Created by liangtong on 2018/4/21.
//

#import "ViewController.h"
#import "LTxCameraShootViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
