//
//  DRWritingView.m
//  CoreML
//
//  Created by Larkin on 2019/1/9.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "DRWritingView.h"

@interface DRPoint : NSObject

@property (nonatomic, assign) CGPoint point;

+ (instancetype)pointWithCGPoint:(CGPoint)point;

@end

@implementation DRPoint

+ (instancetype)pointWithCGPoint:(CGPoint)point {
    DRPoint *p = [[DRPoint alloc] init];
    p.point = point;
    return p;
}

@end



@interface DRWritingView()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) NSMutableArray <DRPoint *> *points;
@property (nonatomic, strong) CAShapeLayer *currentLayer;

@property (nonatomic, strong) NSMutableArray *layerStack;
@property (nonatomic, assign) NSUInteger nextIndex;

@end

@implementation DRWritingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.pan setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan locationInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self begin];
            self.points = [NSMutableArray array];
            [self addPoint:p finish:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [self addPoint:p finish:NO];
            break;
        case UIGestureRecognizerStateEnded:
            [self addPoint:p finish:YES];
            break;
        case UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateCancelled:
            [self addPoint:p finish:YES];
            break;
        case UIGestureRecognizerStateFailed:
            [self addPoint:p finish:YES];
            break;
    }
}

- (void)begin {
    self.currentLayer = [self genLayer];
    [self.layer addSublayer:self.currentLayer];
    self.layerStack = [self.layerStack subarrayWithRange:NSMakeRange(0, self.nextIndex)].mutableCopy;
    [self.layerStack addObject:self.currentLayer];
    self.nextIndex++;
}

- (void)addPoint:(CGPoint)p finish:(BOOL)finished {
    if (!finished && self.points.count) {
        CGPoint _p = self.points.lastObject.point;
        CGVector d = CGVectorMake(p.x - _p.x, p.y - _p.y);
        if (sqrt(d.dx * d.dx + d.dy * d.dy) < 3) {
            return;
        }
    }
    [self.points addObject:[DRPoint pointWithCGPoint:p]];
    if (self.currentLayer) {
        self.currentLayer.path = [self bezierPathWithPoints:self.points].CGPath;
    }
    if (finished) {
        self.currentLayer = nil;
        [self updateImage];
    }
}

- (UIBezierPath *)bezierPathWithPoints:(NSArray <DRPoint *> *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:points[0].point];
    for (int i = 1; i < points.count; i++) {
        CGPoint last = points[i - 1].point;
        CGPoint current = points[i].point;
        CGPoint mid = CGPointMake((last.x + current.x) / 2, (last.y + current.y) / 2);
        [path addQuadCurveToPoint:mid controlPoint:last];
    }
    return path;
}

- (CAShapeLayer *)genLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 10.f;
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineCapRound;
    return layer;
}

- (void)undo {
    if (self.nextIndex) {
        [self.layerStack[self.nextIndex - 1] removeFromSuperlayer];
        self.nextIndex--;
        [self updateImage];
    }
}

- (void)redo {
    if (self.nextIndex < self.layerStack.count) {
        [self.layer addSublayer:self.layerStack[self.nextIndex]];
        self.nextIndex++;
        [self updateImage];
    }
}

- (void)clear {
    if (self.layerStack.count == 0) {
        return;
    }
    for (CALayer *l in self.layerStack) {
        [l removeFromSuperlayer];
    }
    self.layerStack = nil;
    self.nextIndex = 0;
    [self updateImage];
}

- (NSMutableArray *)layerStack {
    if (!_layerStack) {
        _layerStack = [NSMutableArray array];
    }
    return _layerStack;
}

- (void)updateImage {
    UIImage *image = [self imageFromLayer:self.layer];
    if (self.imageDidChange) {
        self.imageDidChange(image);
    }
}

- (UIImage *)imageFromLayer:(CALayer *)layer {
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@end
