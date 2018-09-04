//
//  LTxCameraPreviewViewController.m
//  LTxCamera
//
//  Created by liangtong on 2018/9/3.
//

#import "LTxCameraPreviewPageViewController.h"
#import "LTxCameraPreviewViewController.h"
#import "LTxCameraPhotoPreviewToolbar.h"

@interface LTxCameraPreviewPageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray* photoControllers;
@property (nonatomic, strong) UIButton* selectBtn;
@property (nonatomic, strong) LTxCameraPhotoPreviewToolbar* toolBar;
@end

@implementation LTxCameraPreviewPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self ltxCamera_setupPreviewPageConfig];
    __weak __typeof(self) weakSelf = self;
    _toolBar.okCallback = ^{
        if (weakSelf.okCallback) {
            weakSelf.okCallback(weakSelf.toolBar.useOriginalPhoto);
        }
    };
}

-(void)ltxCamera_setupPreviewPageConfig{
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource = self;
    self.delegate = self;
    _photoControllers = [[NSMutableArray alloc] init];
    for (LTxCameraAssetModel* model in _models) {
        LTxCameraPreviewViewController* previewVC = [[LTxCameraPreviewViewController alloc] init];
        previewVC.model = model;
        [_photoControllers addObject:previewVC];
    }
    
    if (_selectedIndex >= _photoControllers.count) {
        _selectedIndex = 0;
    }
    
    UIViewController* indexVC = [_photoControllers objectAtIndex:_selectedIndex];
    [self setViewControllers:@[indexVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [backBtn setImage:LTxImageWithName(@"ic_navi_back") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(ltxCamera_backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    
    _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    
    [_selectBtn addTarget:self action:@selector(ltxCamera_modelSelectStatusChange) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_selectBtn];
    
    [self ltxCamera_updateRightStatus];
    
    
    [self.view addSubview:self.toolBar];
    NSLayoutConstraint* toolLeading = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0];
    NSLayoutConstraint* toolTrailing = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0];
    NSLayoutConstraint* toolBottom = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
    NSLayoutConstraint* toolHeight = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50];
    
    [NSLayoutConstraint activateConstraints:@[toolLeading,toolTrailing,toolBottom,toolHeight]];
    
    [self ltxCamera_updateToolbar];
    self.toolBar.useOriginalPhoto = _useOriginalPhoto;
}



#pragma mark - UIPageViewControllerDataSource
//翻页控制器进行向前翻页动作 这个数据源方法返回的视图控制器为要显示视图的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [_photoControllers indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }else{
        return _photoControllers[index - 1];
    }
}
//翻页控制器进行向后翻页动作 这个数据源方法返回的视图控制器为要显示视图的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [_photoControllers indexOfObject:viewController];
    if (index >= _photoControllers.count - 1) {
        return nil;//[_dataSouce objectAtIndex:0];
    }else{
        return [_photoControllers objectAtIndex:index + 1];
    }
}
#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    
    if ([pendingViewControllers count] > 0) {
        _selectedIndex = [_photoControllers indexOfObject:pendingViewControllers.lastObject];
    }
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed || finished) {
        if (!completed) {//动画执行，翻页失败
            _selectedIndex =  [_photoControllers indexOfObject:previousViewControllers[0]];
        }
        //根据当前页面更新title
        [self ltxCamera_updateRightStatus];
    }
}
-(void)ltxCamera_updateRightStatus{
    LTxCameraAssetModel* model = [_models objectAtIndex:_selectedIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (model.isSelected) {
            [self.selectBtn setImage:LTxImageWithName(@"ic_photo_selected") forState:UIControlStateNormal];
        }else{
            [self.selectBtn setImage:LTxImageWithName(@"ic_photo_unselected") forState:UIControlStateNormal];
        }
    });
    
    NSString* name = [NSString stringWithFormat:@"%td/%td",_selectedIndex + 1, _models.count];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.title = name;
    });
}

#pragma mark - Action
/**
 * 返回动作
 **/
-(void)ltxCamera_backAction{
    if (![self.navigationController popViewControllerAnimated:true]) {
        [self dismissViewControllerAnimated:true completion:nil];
    };
}

/**
 * 选择动作
 **/
-(void)ltxCamera_modelSelectStatusChange{
    LTxCameraAssetModel* model = [_models objectAtIndex:_selectedIndex];
    
    if (!model.isSelected){
        NSInteger selectCount = 0;
        for (LTxCameraAssetModel* model in _models) {
            if(model.isSelected){
                ++selectCount;
            }
        }
        if (selectCount >= self.maxImagesCount) {
            NSString* tip = [NSString stringWithFormat:[NSBundle ltxCamera_localizedStringForKey:@"Select a maximum of %td photos"],self.maxImagesCount];
            [self ltxCamera_showAlertWithTitle:tip];
            return ;
        }
    }
    
    model.isSelected = !model.isSelected;
    [self ltxCamera_updateRightStatus];
    [self ltxCamera_updateToolbar];
}


- (UIAlertController *)ltxCamera_showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle ltxCamera_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}
/**
 * 更新ToolBar
 **/
-(void)ltxCamera_updateToolbar{
    NSInteger selectCount = 0;
    
    for (LTxCameraAssetModel* model in _models) {
        if(model.isSelected){
            ++selectCount;
        }
    }
    self.toolBar.selectCount = selectCount;
}

-(LTxCameraPhotoPreviewToolbar*)toolBar{
    if (!_toolBar) {
        _toolBar = [[LTxCameraPhotoPreviewToolbar alloc] init];
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        _toolBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    }
    return _toolBar;
}

@end
