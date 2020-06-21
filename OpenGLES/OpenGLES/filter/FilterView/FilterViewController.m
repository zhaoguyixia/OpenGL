//
//  FilterViewController.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterView.h"
#import "FilterTitleCell.h"

@interface FilterViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    FilterView *filterView;
    NSArray *filterArray;
    NSArray *titleArray;
    UIImageView *backImage;
    UICollectionView *collection;
    NSIndexPath *selectIndexPath;
    FilterTitleCell *selectCell;
    NSString *imageName;
}
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, (height-width)/2.0, width, width)];
    filterView.imageName = imageName;
    [self.view addSubview:filterView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 60);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    float y = (height+filterView.frame.origin.y+width)/2.0-50;
    collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, width, 100) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor clearColor];
    collection.delegate = self;
    collection.dataSource = self;
    [collection registerClass:[FilterTitleCell class] forCellWithReuseIdentifier:@"FilterTitleCell"];
    [self.view addSubview:collection];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(30, 120, width-60, 50)];
    slider.maximumValue = 10.0;
    slider.minimumValue = 0.0;
    slider.minimumTrackTintColor = [UIColor cyanColor];
    slider.maximumTrackTintColor = [UIColor blackColor];
    [slider addTarget:self action:@selector(slide:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)slide:(UISlider *)slider{
    NSLog(@"%f", slider.value);
    float vortex = slider.value;
    filterView.vortexSub = vortex;
}

- (void)initData{
    imageName = @"girl2";
    selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    filterArray = @[@"normal", @"split", @"vortex", @"mosaic", @"soul", @"gray"];
    titleArray = @[@"正常", @"分屏", @"旋涡", @"马赛克", @"灵魂", @"灰度"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterTitleCell" forIndexPath:indexPath];
    [cell setTitle:titleArray[indexPath.row]];
    if (selectIndexPath != nil && indexPath.row == selectIndexPath.row) {
        cell.isSelected = YES;
        selectCell = cell;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [titleArray count];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (selectIndexPath.row == indexPath.row) {
        return;
    }
    
    if (selectCell) {
        selectCell.isSelected = NO;
    }
    FilterTitleCell *cell = (FilterTitleCell *)[collectionView cellForItemAtIndexPath:selectIndexPath];
    cell.isSelected = NO;
    selectIndexPath = indexPath;
    cell = (FilterTitleCell *)[collectionView cellForItemAtIndexPath:selectIndexPath];
    cell.isSelected = YES;
    selectCell = cell;
    
    NSString *name = filterArray[indexPath.row];
    filterView.filterName = name;
}

@end
