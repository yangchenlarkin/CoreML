//
//  HomeTableViewController.m
//  CoreML
//
//  Created by Larkin on 2019/1/10.
//  Copyright © 2019 Larkin. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ObjectRecognition/ORViewController.h"

@interface HomeTableViewController ()

@property (nonatomic, copy) NSArray <NSString *> *viewControllerNames;
@property (nonatomic, copy) NSArray <NSString *> *viewControllerTitles;

@end

@implementation HomeTableViewController

- (instancetype)init {
    if (self = [super init]) {
        self.viewControllerNames =
        @[
          @"ORViewController",
          ];
        
        self.viewControllerTitles =
        @[
          @"物品识别",
          ];
    }
    return self;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.viewControllerTitles[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewControllerNames.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    NSString *vcName = self.viewControllerNames[indexPath.row];
    Class vcClass = NSClassFromString(vcName);
    UIViewController *vc = [[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = self.viewControllerTitles[indexPath.row];
}

@end

