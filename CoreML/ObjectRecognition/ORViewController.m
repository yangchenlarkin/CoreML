//
//  ORViewController.m
//  CoreML
//
//  Created by Larkin on 2019/1/8.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "ORViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "ORCameraView.h"

@interface ORViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) ORCameraView *cameraView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, copy) NSArray <NSArray <NSString *> *> *array;

@end

@implementation ORViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    self.cameraView = [[ORCameraView alloc] initWithFrame:CGRectMake(0, 64, width - 20, width - 20)];
    self.cameraView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.cameraView];
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(10, 64 + width - 20 + 10, width - 20, 40.f)];
    self.button.backgroundColor = [UIColor blueColor];
    [self.button setTitle:@"What's this?" forState:UIControlStateNormal];
    
    [self.button setTitle:@"Please wait..." forState:UIControlStateDisabled];
    
    [self.button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    CGFloat top = self.button.frame.origin.y + self.button.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, width, height - top)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped = YES;
    self.indicatorView.center = self.tableView.center;
    [self.view addSubview:self.indicatorView];
    
    [self.cameraView begin];
}

- (void)click {
    if (self.cameraView.isRunning) {
        [self getImage];
        [self.button setTitle:@"OK" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor greenColor];
    } else {
        [self.cameraView begin];
        self.button.backgroundColor = [UIColor blueColor];
        [self.button setTitle:@"What's this?" forState:UIControlStateNormal];
        self.array = nil;
    }
}

- (void)getImage {
    self.button.enabled = NO;
    [self.indicatorView startAnimating];
    __weak typeof(self) _self = self;
    [self.cameraView getImageWithCallBack:^(UIImage * _Nonnull image) {
        typeof(_self) self = _self;
        [self predict:image];
        
        self.button.enabled = YES;
        [self.indicatorView stopAnimating];
    }];
}

#pragma mark - table view

- (void)setArray:(NSArray<NSArray<NSString *> *> *)array {
    if (_array != array) {
        _array = array;
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifier"];
    }
    cell.textLabel.text = self.array[indexPath.row][0];
    cell.detailTextLabel.text = self.array[indexPath.row][1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

#pragma mark - predict

- (void)predict:(UIImage *)image {
    //TODO
}

@end
