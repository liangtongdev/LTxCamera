//
//  LTxCameraPhotoPickerViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraPhotoPickerViewController.h"
#import "LTxCameraPhotoCollectionViewCell.h"
#import "LTxCameraPhotoPickerToolBar.h"
#import "LTxCameraWaitingView.h"
#import "LTxCameraPreviewPageViewController.h"//预览

#define LTxCameraPhotoCollectionViewCellIdentifier @"LTxCameraPhotoCollectionViewCellIdentifier"//照片

@interface LTxCameraPhotoPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) LTxCameraWaitingView* waitingView;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) LTxCameraPhotoPickerToolBar* toolBar;
@property (nonatomic, strong) NSMutableArray* selectAssets;

//信号量，单线程执行
@property (nonatomic, strong) dispatch_semaphore_t semaphore;//信号量，用于限制最大上传个数
@property (nonatomic, strong) dispatch_queue_t queue;//信号队列

@end

@implementation LTxCameraPhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ltxCamera_setupPhotoPickerView];
    
    [self ltxCamera_updateToolbar];
    
    __weak __typeof(self) weakSelf = self;
    //预览-回调
    _toolBar.previewCallback = ^{
        //预览已经选择的照片
        [weakSelf ltxCamera_previewAction:-1];
    };
    //完成回调
    _toolBar.okCallback = ^{
        //完成选择，回传完成
        [weakSelf ltxCamera_finishAction];
    };
}

#pragma mark - Action

/***
 * 导航栏右上角取消按钮
 **/
-(void)ltxCamera_rightNaviCloseAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 * 更新ToolBar
 **/
-(void)ltxCamera_updateToolbar{
    [self.selectAssets removeAllObjects];
    
    for (LTxCameraAssetModel* model in _model.models) {
        if(model.isSelected){
            [self.selectAssets addObject:model];
        }
    }
    
    NSInteger selectCount = [_selectAssets count];
    _toolBar.selectCount = selectCount;
}


/***
 * 预览动作
 **/
-(void)ltxCamera_previewAction:(NSInteger)index{
    if (index == -1) {
        if ([_selectAssets count] == 0) {
            return;
        }
    }
    __weak __typeof(self) weakSelf = self;
    LTxCameraPreviewPageViewController* pageVC = [[LTxCameraPreviewPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.maxImagesCount = self.maxImagesCount;
    if (index == -1) {
        pageVC.models = _selectAssets;
        pageVC.selectedIndex = 0;
    }else{
        pageVC.models = self.model.models;
        pageVC.selectedIndex = index;
    }
    
    pageVC.okCallback = ^{
        [weakSelf ltxCamera_updateToolbar];
        [weakSelf ltxCamera_finishAction];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:pageVC animated:true];
    });
}


/***
 * 完成动作
 **/
-(void)ltxCamera_finishAction{
    
    if ([self.photoPickerDelegate respondsToSelector:@selector(ltxCamera_photoPickerWillFinish)]) {
        [self.photoPickerDelegate ltxCamera_photoPickerWillFinish];
    }
    
    [self.waitingView show];
    
    BOOL export = YES;
    if ([self.photoPickerDataSource respondsToSelector:@selector(ltx_cameraExportPickerFiles)]) {
        export = [self.photoPickerDataSource ltx_cameraExportPickerFiles];
    }
    
    NSMutableArray* thumbPhotos = [[NSMutableArray alloc] init];
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    NSMutableArray* paths = [[NSMutableArray alloc] init];
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(1);
    }
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    __weak __typeof(self) weakSelf = self;
    for (LTxCameraAssetModel* model in _selectAssets) {
        PHAsset* asset = model.asset;
        dispatch_async(_queue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@"开始导出照片/视频");
            //第一步，首先获取照片
            if (model.thumbImage) {
                [thumbPhotos addObject:model.thumbImage];
            }
            if (model.originalImage) {
                [photos addObject:model.originalImage];
                
                if (!export) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dispatch_semaphore_signal(self.semaphore);
                    });
                    return ;
                }
                
                //第二步，导出地址
                if (asset.mediaType == PHAssetMediaTypeImage) {
                    [LTxCameraUtil exportImage:model.originalImage completion:^(NSString * path, NSString *error) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        if (path) {
                            [paths addObject:path];
                        }
                        NSLog(@"结束导出照片:%@",path);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            dispatch_semaphore_signal(strongSelf.semaphore);
                        });
                    }];
                }else{
                    [LTxCameraUtil exportVideoWithAsset:asset presetName:nil completion:^(NSString* path, NSString *error) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        if (path) {
                            [paths addObject:path];
                        }
                        NSLog(@"开始导出视频:%@",path);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            dispatch_semaphore_signal(strongSelf.semaphore);
                        });
                    }];
                }
            }
        });
    }//end for
    
    dispatch_async(_queue, ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"完成1");
        //信号量等待
        if ([self.photoPickerDelegate respondsToSelector:@selector(ltxCamera_photoPickerDidFinishPickingPhotos:thumbPhotos:paths:sourceAssets:isSelectOriginalPhoto:)]) {
            [self.photoPickerDelegate ltxCamera_photoPickerDidFinishPickingPhotos:photos thumbPhotos:thumbPhotos paths:paths sourceAssets:self.selectAssets isSelectOriginalPhoto:self.toolBar.useOriginalPhoto];
        }
        NSLog(@"完成2");
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_signal(self.semaphore);
            [self.waitingView hide];
            [self ltxCamera_rightNaviCloseAction];
        });
    });
    
}



- (UIAlertController *)ltxCamera_showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ltxCamera_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

#pragma mark - UI
/**
 * UI
 **/
-(void)ltxCamera_setupPhotoPickerView{
    self.navigationItem.title = _model.name;
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 26)];
    [cancelBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(ltxCamera_rightNaviCloseAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LTxCameraPhotoCollectionViewCell class] forCellWithReuseIdentifier:LTxCameraPhotoCollectionViewCellIdentifier];
    
    [self.view addSubview:self.toolBar];
    
    [self.view addSubview:self.waitingView];
    
    [self ltxCamera_addConstraintOnPickerView];
    
    [self.waitingView hide];
}

-(void)ltxCamera_addConstraintOnPickerView{
    NSLayoutConstraint* collectionLead = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* collectionTop = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* collectionTrailing = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    
    [NSLayoutConstraint activateConstraints:@[collectionLead,collectionTop,collectionTrailing]];
    
    NSLayoutConstraint* toolLeading = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* toolTop = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    NSLayoutConstraint* toolTrailing = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* toolBottom = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    NSLayoutConstraint* toolHeight = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50];
    
    [NSLayoutConstraint activateConstraints:@[toolLeading,toolTop,toolTrailing,toolBottom,toolHeight]];
    
    
    NSLayoutConstraint* waitingLead = [NSLayoutConstraint constraintWithItem:_waitingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* waitingTop = [NSLayoutConstraint constraintWithItem:_waitingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0];
    NSLayoutConstraint* waitingTrailing = [NSLayoutConstraint constraintWithItem:_waitingView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* waitingBottom = [NSLayoutConstraint constraintWithItem:_waitingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    [NSLayoutConstraint activateConstraints:@[waitingLead,waitingTop,waitingTrailing,waitingBottom]];
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemWidth = collectionView.frame.size.width / 4 - 1;
    return CGSizeMake(itemWidth, itemWidth);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.model.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LTxCameraPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LTxCameraPhotoCollectionViewCellIdentifier forIndexPath:indexPath];
    LTxCameraAssetModel* model = [self.model.models objectAtIndex:indexPath.row];
    cell.model = model;
    cell.selectCallback = ^{
        if (!model.isSelected){
            NSInteger count = [self.selectAssets count];
            if (count >= self.maxImagesCount) {
                NSString* tip = [NSString stringWithFormat:[NSBundle ltxCamera_localizedStringForKey:@"Select a maximum of %td photos"],self.maxImagesCount];
                [self ltxCamera_showAlertWithTitle:tip];
                return ;
            }
        }
        model.isSelected = !model.isSelected;
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        });
        [self ltxCamera_updateToolbar];
    };
    return cell;
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    [self ltxCamera_previewAction:indexPath.row];
}

#pragma mark - Getter
-(LTxCameraWaitingView*)waitingView{
    if (!_waitingView) {
        _waitingView = [[LTxCameraWaitingView alloc] init];
    }
    return _waitingView;
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

-(LTxCameraPhotoPickerToolBar*)toolBar{
    if (!_toolBar) {
        _toolBar = [[LTxCameraPhotoPickerToolBar alloc] init];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        _toolBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    }
    return _toolBar;
}

-(NSMutableArray*)selectAssets{
    if (!_selectAssets){
        _selectAssets = [[NSMutableArray alloc] init];
    }
    return _selectAssets;
}
@end
