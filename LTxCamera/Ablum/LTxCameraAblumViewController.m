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
@property (nonatomic, strong) LTxCameraAblumTableViewController* ablumTableVC;
@end

@implementation LTxCameraAblumViewController

- (instancetype)init{
    self = [super initWithRootViewController:self.ablumTableVC];
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

-(void)setPhotoPickerDataSource:(id<LTxCameraPhotoPickerDataSource>)photoPickerDataSource{
    _photoPickerDataSource = photoPickerDataSource;
    self.ablumTableVC.photoPickerDataSource = photoPickerDataSource;
}
-(void)setPhotoPickerDelegate:(id<LTxCameraPhotoPickerDelegate>)photoPickerDelegate{
    _photoPickerDelegate = photoPickerDelegate;
    self.ablumTableVC.photoPickerDelegate = photoPickerDelegate;
}

-(void)setMaxImagesCount:(NSInteger)maxImagesCount{
    _maxImagesCount = maxImagesCount;
    self.ablumTableVC.maxImagesCount = maxImagesCount;
}

-(LTxCameraAblumTableViewController*)ablumTableVC{
    if (!_ablumTableVC) {
        _ablumTableVC = [[LTxCameraAblumTableViewController alloc] init];
    }
    return _ablumTableVC;
}

-(void)dealloc{
    _ablumTableVC.photoPickerDataSource = nil;
    _ablumTableVC.photoPickerDelegate = nil;
    _ablumTableVC = nil;
}

@end



#pragma mark - 相册的跟视图

@interface LTxCameraAblumTableViewController()
@property (nonatomic, strong) NSMutableArray* albumList;//相册列表
@property (nonatomic, strong) UILabel* tipL;//在访问权限受限的情况下，提示信息

@end

@implementation LTxCameraAblumTableViewController : UITableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self ltxCamera_setupAblumTableView];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //检查权限，如果用户尚未授权使用相册，则弹出授权框
    PHAuthorizationStatus status = [self photoAuthorizationStatusCheck];
    if (status == PHAuthorizationStatusNotDetermined) {
        [self showNotAuthorizationTip];
    }else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
        [self showNotAuthorizationTip];
    }else if (status == PHAuthorizationStatusAuthorized){
        [self.tipL removeFromSuperview];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

#pragma mark - PhotoAuthorization
/**
 * 检查相册权限
 **/
-(PHAuthorizationStatus)photoAuthorizationStatusCheck{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
                if (newStatus == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tipL removeFromSuperview];
                        [self showPhotosInAblum:nil] ;
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    });
                    [self reloadAlbumTableView];
                }else{
                    [self showNotAuthorizationTip];
                }
            }];
        });
    }else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
        [self showNotAuthorizationTip];
    }else if (status == PHAuthorizationStatusAuthorized){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tipL removeFromSuperview];
            [self showPhotosInAblum:nil] ;
        });
    }
    return status;
}

-(void)showNotAuthorizationTip{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        self.tipL.text = [NSString stringWithFormat:[NSBundle ltxCamera_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
    });
}

#pragma mark - UI
/**
 * UI
 **/
-(void)ltxCamera_setupAblumTableView{
    
    self.navigationItem.title = [NSBundle ltxCamera_localizedStringForKey:@"Photos"];
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 26)];
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
    
    photoPicker.photoPickerDataSource = self.photoPickerDataSource;
    photoPicker.photoPickerDelegate = self.photoPickerDelegate;
    photoPicker.maxImagesCount = self.maxImagesCount < 1 ? 9 : self.maxImagesCount;
    
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

/**
 * 刷新列表
 **/
-(void)reloadAlbumTableView{
    _albumList = [LTxCameraUtil getAllAlbumListWithOpinion:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
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

-(UILabel*)tipL{
    if (!_tipL) {
        _tipL = [[UILabel alloc] init];
        _tipL.textAlignment = NSTextAlignmentCenter;
        _tipL.translatesAutoresizingMaskIntoConstraints = NO;
        _tipL.numberOfLines = 0;
        
        [self.view addSubview:_tipL];
        NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:_tipL attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0];
        NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:_tipL attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:100];
        [NSLayoutConstraint activateConstraints:@[centerX,top]];
    }
    return _tipL;
}


-(void)setPhotoPickerDataSource:(id<LTxCameraPhotoPickerDataSource>)photoPickerDataSource{
    _photoPickerDataSource = photoPickerDataSource;
}
-(void)setPhotoPickerDelegate:(id<LTxCameraPhotoPickerDelegate>)photoPickerDelegate{
    _photoPickerDelegate = photoPickerDelegate;
}



@end
