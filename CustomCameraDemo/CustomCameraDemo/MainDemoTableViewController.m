//
//  MainDemoTableViewController.m
//  CustomCameraDemo
//
//  Created by liangtong on 2018/8/31.
//

#import "MainDemoTableViewController.h"
#import "LTxCamera.h"
@interface MainDemoTableViewController ()

@end

@implementation MainDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* identifier = cell.reuseIdentifier;
    if ([identifier isEqualToString:@"qr-scan"]){
        LTxCameraScanViewController* scanVC = [[LTxCameraScanViewController alloc] init];
        scanVC.scanCallback = ^(NSString *qrcode) {
            NSLog(@"qrcode : %@",qrcode);
        };
        [self.navigationController pushViewController:scanVC animated:NO];
    }else if ([identifier isEqualToString:@"camera"]){
        LTxCameraShootViewController* cameraShootVC = [[LTxCameraShootViewController alloc] init];
        cameraShootVC.allowTakePhoto = YES;
        cameraShootVC.allowRecordVideo = YES;
        cameraShootVC.maxRecordDuration = 15;
        cameraShootVC.shootDoneCallback = ^(UIImage* image, NSURL* videoPath, PHAsset *asset){
            
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:cameraShootVC animated:NO completion:nil];
        });
    }else if ([identifier isEqualToString:@"ablum"]){
        LTxCameraAblumViewController* ablumVC = [[LTxCameraAblumViewController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:ablumVC animated:YES completion:nil];
        });
        
       
    }
}


@end
