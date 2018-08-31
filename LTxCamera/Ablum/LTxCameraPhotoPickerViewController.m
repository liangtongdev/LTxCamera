//
//  LTxCameraPhotoPickerViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/8/31.
//

#import "LTxCameraPhotoPickerViewController.h"
#import "LTxCameraPhotoCollectionViewCell.h"
#import "LTxCameraPhotoPickerToolBar.h"

#define LTxCameraPhotoCollectionViewCellIdentifier @"LTxCameraPhotoCollectionViewCellIdentifier"//照片

@interface LTxCameraPhotoPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) LTxCameraPhotoPickerToolBar* toolBar;
@property (nonatomic, strong) NSMutableArray* selectAssets;
@end

@implementation LTxCameraPhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ltxCamera_setupPhotoPickerView];
    
    [self ltxCamera_updateToolbar];
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


#pragma mark - UI
/**
 * UI
 **/
-(void)ltxCamera_setupPhotoPickerView{
    self.navigationItem.title = _model.name;
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 26)];
    [cancelBtn setTitle:[NSBundle ltxCamera_localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn addTarget:self action:@selector(ltxCameraCancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[LTxCameraPhotoCollectionViewCell class] forCellWithReuseIdentifier:LTxCameraPhotoCollectionViewCellIdentifier];
    
    [self.view addSubview:self.toolBar];
    
    [self ltxCamera_addConstraintOnPickerView];
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
    
    
    
    
}

#pragma mark - Getter
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
