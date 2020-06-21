//
//  ViewController.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cyanColor];
    self.title = @"OpenGL ES";
    self.dataSource = @[@"TextureViewController",
                        @"FilterViewController",
                        @"OutputFilterImageViewController",
                        @"ComposeVideoViewController"];
    self.titleArray = @[@"加载纹理",
                        @"各种滤镜",
                        @"给图片加滤镜",
                        @"视频合成"];
    [self createUI];
}

- (void)createUI{
    self.tableView    = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.dataSource         = self;
    self.tableView.delegate           = self;
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    if ([self.titleArray count]) {
        NSString *str = [self.titleArray objectAtIndex:indexPath.row];
        cell.textLabel.text = str;
    }
    cell.selectionStyle = 0;
    return cell;
}

-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *className = [self.dataSource objectAtIndex:indexPath.row];
    Class view = NSClassFromString(className);
    UIViewController *viewController = [[view alloc] init];
    viewController.title = self.titleArray[indexPath.row];
    if (viewController==nil) {
        
        view = NSClassFromString([@"OpenGLES." stringByAppendingString:className]);
        viewController = [[view alloc] init];
        
        viewController.title = self.titleArray[indexPath.row];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
//}

@end
