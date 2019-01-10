//
//  ORCameraView.m
//  CoreML
//
//  Created by Larkin on 2019/1/8.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "ORCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface ORCameraView() <AVCapturePhotoCaptureDelegate>
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) void (^callBack)(UIImage *image);

@end

@implementation ORCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //    AVCaptureDevicePositionBack  后置摄像头
        //    AVCaptureDevicePositionFront 前置摄像头
        self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
        
        self.imageOutput = [[AVCapturePhotoOutput alloc] init];
        NSDictionary *setDic = @{AVVideoCodecKey: AVVideoCodecTypeJPEG};
        AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [self.imageOutput setPhotoSettingsForSceneMonitoring:settings];
        
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        
        //输入输出设备结合
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
        if ([self.session canAddOutput:self.imageOutput]) {
            [self.session addOutput:self.imageOutput];
        }
        
        //预览层的生成
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.previewLayer.frame = self.bounds;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:self.previewLayer];
    }
    return self;
}

- (void)begin {
    [self.session startRunning];
}

- (void)stop {
    [self.session stopRunning];
}

- (BOOL)isRunning {
    return self.session.isRunning;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *deviceSessions =
    [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                           mediaType:AVMediaTypeVideo
                                                            position:position];
    
    NSArray *devices  = deviceSessions.devices;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)getImageWithCallBack:(void (^)(UIImage * _Nonnull))callBack {
    if (!self.callBack && callBack) {
        self.callBack = callBack;
        AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettings];
        setting.flashMode = AVCaptureFlashModeOff;
        [self.imageOutput capturePhotoWithSettings:setting delegate:self];
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    NSData *imageData = [photo  fileDataRepresentation];
    self.callBack([UIImage imageWithData:imageData]);
    self.callBack = NULL;
    [self stop];
}

@end
