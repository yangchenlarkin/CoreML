//
//  DRViewController.m
//  CoreML
//
//  Created by Larkin on 2019/1/9.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "DRViewController.h"
#import "DRWritingView.h"

@interface DRViewController ()

@property (nonatomic, strong) DRWritingView *writingView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIButton *undo;
@property (nonatomic, strong) UIButton *redo;
@property (nonatomic, strong) UIButton *clear;

@end

@implementation DRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    self.writingView = [[DRWritingView alloc] initWithFrame:CGRectMake(0, 64, width, width)];
    self.writingView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.writingView];
    
    self.undo = [[UIButton alloc] initWithFrame:CGRectMake(10, 64 + width + 5, 44, 44)];
    self.undo.backgroundColor = [UIColor orangeColor];
    [self.undo setTitle:@"<-" forState:UIControlStateNormal];
    [self.undo addTarget:self.writingView action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.undo];
    
    self.redo = [[UIButton alloc] initWithFrame:CGRectMake(width - 10 - 44, 64 + width + 5, 44, 44)];
    self.redo.backgroundColor = [UIColor orangeColor];
    [self.redo setTitle:@"->" forState:UIControlStateNormal];
    [self.redo addTarget:self.writingView action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.redo];
    
    self.clear = [[UIButton alloc] initWithFrame:CGRectMake(10 + 44 + 10,
                                                            64 + width + 5,
                                                            width - 10 * 4 - 44 * 2,
                                                            44)];
    self.clear.backgroundColor = [UIColor orangeColor];
    [self.clear setTitle:@"Clear" forState:UIControlStateNormal];
    [self.clear addTarget:self.writingView action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clear];
    
    CGFloat top = 64 + width + 5 + 44 + 5;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, top, width, height - top)];
    self.label.font = [UIFont boldSystemFontOfSize:40];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"在黑色区域书写数字";
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
    
    __weak typeof(self) _self = self;
    self.writingView.imageDidChange = ^(UIImage * _Nonnull image) {
        typeof(_self) self = _self;
        self.label.text = [self predict:image];
    };
}

#pragma mark - predict

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]
                              };
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_OneComponent8,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNone);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (UIImage*)scaleImage:(UIImage *)image size:(CGFloat)size {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), YES, 1);
    
    CGFloat x, y, w, h;
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    if (imageW > imageH) {
        w = imageW / imageH * size;
        h = size;
        x = (size - w) / 2;
        y = 0;
    } else {
        h = imageH / imageW * size;
        w = size;
        y = (size - h) / 2;
        x = 0;
    }
    
    // 将图片按照指定大小绘制
    [image drawInRect:CGRectMake(x, y, w, h)];
    
    // 从当前图片上下文中导出图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 当前图片上下文出栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (NSString *)predict:(UIImage *)image {
    return @"TODO";
}

@end
