//
//  ComposeVideoViewController.m
//  OpenGLES
//
//  Created by wantexe on 2020/5/25.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "ComposeVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import <AVKit/AVKit.h>
#import "VideoDirector.h"

#import "GPUImage.h"

@interface ComposeVideoViewController ()
{
    NSMutableArray*imageArr;    //未压缩的图片
    NSMutableArray*imageArray;  //经过压缩的图片
    VideoDirector *videoDirector;
    UIImageView *imageView;
    UIView *showView;
}

//视频地址
@property(nonatomic,strong) NSString *theVideoPath;
//合成进度
@property(nonatomic,strong) UILabel *ww_progressLbe;
@end

@implementation ComposeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width = self.view.frame.size.width;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, width, width)];
    [self.view addSubview:imageView];
    
//    showView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, width, width)];
//    [self.view addSubview:showView];
    
//    [self ww_setupInit];
    [self setupUI];
}

- (void)setupUI{
//    [self composeVideo];
    
    UIImage *inputImage = [UIImage imageNamed:@"video_demo_8"];
    
    int ii = 1;
    if (ii == 1) {
        videoDirector = [VideoDirector new];
        [videoDirector bindView:imageView];
        [videoDirector setImage:inputImage];
        imageView.image = [videoDirector getProcessImage];
    }else{
        GPUImageSketchFilter *passthroughFilter = [[GPUImageSketchFilter alloc] init];

        // 3.设置参数(要渲染的区域)

        [passthroughFilter forceProcessingAtSize:inputImage.size];

        [passthroughFilter useNextFrameForImageCapture];

        // 4.获取数据源(将UIImage对象给GPUImagePicture)

        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];

        // 5.给数据源添加滤镜

        [stillImageSource addTarget:passthroughFilter];

        // 6.开始渲染

        [stillImageSource processImage];

        // 7.获取渲染后的图片

        UIImage *newImage = [passthroughFilter imageFromCurrentFramebuffer];
        imageView.image = newImage;
    }
    
    
}

- (void)ww_setupInit {
    
    imageArray = [[NSMutableArray alloc]init];
    imageArr = [[NSMutableArray alloc]init];
    
    NSString *name = @"";
    UIImage *img = nil;
    
    //实先准备21张图片，命名为0.jpg至21.jpg
    for (int i = 0; i < 10; i++) {
        name = [NSString stringWithFormat:@"video_demo_%d",i];
        img = [UIImage imageNamed:name];
        [imageArr addObject:img];
    }
   
    //对图片进行裁剪，方便合成等比例视频
    for (int i = 0; i < imageArr.count; i++) {
        
        UIImage *imageNew = imageArr[i];
        
        //设置image的尺寸
        CGSize imgeSize = CGSizeMake(320, 480);
        
        //对图片大小进行压缩--
        imageNew = [self imageWithImage:imageNew scaledToSize:imgeSize];
        
        [imageArray addObject:imageNew];
    }
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    // 新创建的位图上下文 newSize为其大小
    UIGraphicsBeginImageContext(newSize);
    // 对图片进行尺寸的改变
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // 从当前上下文中获取一个UIImage对象  即获取新的图片对象
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)composeVideo{
    //设置mov路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);

    NSString *moviePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];

    self.theVideoPath = moviePath;
    CGSize size =  CGSizeMake(320, 480);
    NSError *error = nil;
    
    unlink([moviePath UTF8String]);
    
    NSLog(@"path %@", moviePath);
    
    AVAssetWriter *videoWrite = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath] fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error != nil) {
        NSLog(@"write init fail");
        return;
    }
    
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264,AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferInfo];
    
    [videoWrite addInput:writerInput];
    
    [videoWrite startWriting];
    
    [videoWrite startSessionAtSourceTime:kCMTimeZero];
    
    
    //合成多张图片为一个视频文件
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue",NULL);
    
    int __block frame = 0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        
        while([writerInput isReadyForMoreMediaData]) {
            
            if(++frame >= [imageArray count] * 10) {
                
                [writerInput markAsFinished];
                
                [videoWrite finishWritingWithCompletionHandler:^{
                    NSLog(@"完成");
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        self.ww_progressLbe.text = @"视频合成完毕";
                        
                    }];

                }];
                break;
            }
            
            CVPixelBufferRef buffer = NULL;
            
            int idx = frame / 10;
            
            NSLog(@"idx==%d",idx);
            NSString *progress = [NSString stringWithFormat:@"%0.2lu",idx / [imageArr count]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                self.ww_progressLbe.text = [NSString stringWithFormat:@"合成进度:%@",progress];
                
            }];

            
            buffer = [self pixelBufferFromCGImage:[[imageArray objectAtIndex:idx] CGImage] size:size];
            
            if(buffer){
                
                //设置每秒钟播放图片的个数
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,10)]) {
                    
                    NSLog(@"FAIL");
                    
                } else {
                    
                    NSLog(@"OK");
                }
                
                CFRelease(buffer);
            }
        }
    }];
    
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                           
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata !=NULL);
    
    // 色彩空间
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。
    // 当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。
    // 一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项
    
    CGContextRef context = CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    
    // 使用CGContextDrawImage绘制图片  这里设置不正确的话 会导致视频颠倒
    
    // 当通过CGContextDrawImage绘制图片到一个context中时，如果传入的是UIImage的CGImageRef，因为UIKit和CG坐标系y轴相反，所以图片绘制将会上下颠倒
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    // 释放色彩空间
    CGColorSpaceRelease(rgbColorSpace);
    
    // 释放context
    CGContextRelease(context);
    
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

@end
