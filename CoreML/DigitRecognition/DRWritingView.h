//
//  DRWritingView.h
//  CoreML
//
//  Created by Larkin on 2019/1/9.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRWritingView : UIView

@property (nonatomic, copy) void (^imageDidChange)(UIImage * _Nullable image);

- (void)undo;
- (void)redo;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
