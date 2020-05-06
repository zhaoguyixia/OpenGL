//
//  TextureViewController.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "TextureViewController.h"
#import "TextureView.h"

@interface TextureViewController ()

@end

@implementation TextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI{
    TextureView *textureView = [[TextureView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:textureView];
}

@end
