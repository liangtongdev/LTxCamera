//
//  QRCodeViewController.m
//  CustomCameraDemo
//
//  Created by liangtong on 2018/4/27.
//

#import "QRCodeViewController.h"
#import "LTxQRCodeGenerate.h"
@interface QRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"QRCode Demo";
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [LTxQRCodeGenerate fillQRImageWithImageView:_imageView qrString:@"Hello world!"];
    
//    UIImage* qrImage = [LTxQRCodeGenerate createQRImageWithString:@"Hello world!" size:240 red:255  green:0 blue:0];
//    self.imageView.image = qrImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
