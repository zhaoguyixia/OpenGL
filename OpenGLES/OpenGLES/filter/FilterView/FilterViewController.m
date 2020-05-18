//
//  FilterViewController.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/10.
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
    UICollectionView *collection;
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
    filterArray = @[@"normal", @"split", @"vortex"];
    titleArray = @[@"正常", @"分屏", @"旋涡"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterTitleCell" forIndexPath:indexPath];
    [cell setTitle:titleArray[indexPath.row]];
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [titleArray count];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *name = filterArray[indexPath.row];
    filterView.filterName = name;
}

@end
