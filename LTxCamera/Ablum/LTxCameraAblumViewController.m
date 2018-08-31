//
//  LTxCameraAblumViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraAblumViewController.h"
#import "LTxCameraAblumTableViewCell.h"//相册
#import "LTxCameraPhotoPickerViewController.h"



#define  LTxCameraAblumTableViewCellIdentifier @"LTxCameraAblumTableViewCellIdentifier"
@interface LTxCameraAblumViewController ()

@end

@implementation LTxCameraAblumViewController

- (instancetype)init{
    LTxCameraAblumTableViewController* ablumTableVC = [[LTxCameraAblumTableViewController alloc] init];
    self = [super initWithRootViewController:ablumTableVC];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSDictionary *textAttrs = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.titleTextAttributes = textAttrs;
    
}




@end



#pragma mark - 相册的跟视图

@interface LTxCameraAblumTableViewController()
@property (nonatomic, strong) NSMutableArray* albumList;//相册列表
@end

@implementation LTxCameraAblumTableViewController : UITableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self ltxCamera_setupAblumTableView];
    [self showPhotosInAblum:nil] ;
}

#pragma mark - UI
/**
 * UI
 **/
-(void)ltxCamera_setupAblumTableView{
    
    self.navigationItem.title = [NSBundle ltxCamera_localizedStringForKey:@"Photos"];
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 26)];
    [cancelBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn addTarget:self action:@selector(ltxCameraCancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    
    [self.tableView registerClass:[LTxCameraAblumTableViewCell class] forCellReuseIdentifier:LTxCameraAblumTableViewCellIdentifier];
    self.tableView.rowHeight = 68.f;
}

#pragma mark - Action

/***
 * 导航栏右上角取消按钮
 **/
-(void)ltxCameraCancelAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 * 展示相册
 * 首次加载的时候，会默认将本页面推入，默认加载相机胶卷内的相片
 **/
-(void)showPhotosInAblum:(LTxCameraAlbumModel*)album{
    LTxCameraPhotoPickerViewController* photoPicker = [[LTxCameraPhotoPickerViewController alloc] init];
    
    BOOL animate = NO;
    if (album) {
        photoPicker.model = album;
        animate = YES;
    }else{
        photoPicker.model = [LTxCameraUtil getCameraRollAlbum];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:photoPicker animated:animate];
    });
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.albumList count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LTxCameraAblumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LTxCameraAblumTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[LTxCameraAblumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LTxCameraAblumTableViewCellIdentifier];
    }
    cell.model = [_albumList objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self showPhotosInAblum:[_albumList objectAtIndex:indexPath.row]];
}

#pragma mark - Getter
-(NSMutableArray*)albumList{
    if(!_albumList){
        _albumList = [LTxCameraUtil getAllAlbumListWithOpinion:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    return _albumList;
}

@end
