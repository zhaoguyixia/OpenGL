//
//  TextureViewController.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "TextureViewController.h"
#import "TextureView.h"

@interface TextureViewController ()
{
    TextureView *textureView;
}
@end

@implementation TextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
//    [self setupUI];
}

- (void)setupUI{
    float y = (self.view.frame.size.height-self.view.frame.size.width)/2.0;
    float w = self.view.frame.size.width;
    float h = self.view.frame.size.width;
    textureView = [[TextureView alloc] initWithFrame:CGRectMake(0, y, w, h)];
    [self.view addSubview:textureView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (textureView == nil) {
        [self setupUI];
    }
}

@end
