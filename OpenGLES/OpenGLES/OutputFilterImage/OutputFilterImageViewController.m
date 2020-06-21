//
//  OutputFilterImageViewController.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/6/21.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//
/*
 给图片加滤镜并导出图片
 */

#import "OutputFilterImageViewController.h"
#import "OutputFilterImageManager.h"

@interface OutputFilterImageViewController ()
{
    UIImageView *imageView;
}
@end

@implementation OutputFilterImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width = self.view.frame.size.width;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, width, width)];
    [self.view addSubview:imageView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIImage *inputImage = [UIImage imageNamed:@"video_demo_8"];
        
    OutputFilterImageManager *filterManager = [OutputFilterImageManager new];
    [filterManager setTextureSize:inputImage.size];
    [filterManager setImage:inputImage];
    [filterManager render];
    
    UIImage *processImage = [filterManager getProcessImage];
    imageView.image = processImage;
}

@end
