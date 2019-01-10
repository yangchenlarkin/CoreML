//
//  ORCameraView.h
//  CoreML
//
//  Created by Larkin on 2019/1/8.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ORCameraView : UIView

@property (nonatomic, readonly) BOOL isRunning;

- (void)begin;
- (void)getImageWithCallBack:(void (^)(UIImage *image))callBack;

@end

NS_ASSUME_NONNULL_END
