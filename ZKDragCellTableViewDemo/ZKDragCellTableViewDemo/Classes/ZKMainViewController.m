//
//  ZKMainViewController.m
//  ZKDragCellTableViewDemo
//
//  Created by ZK on 16/3/2.
//  Copyright © 2016年 ZK. All rights reserved.
//

#define ZKColor(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
#define ZKRandomColor ZKColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 1)

#import "ZKMainViewController.h"
#import "ZKDragCellTableView.h"
#import "ZKModel.h"
#import "ZKCell.h"

@interface ZKMainViewController () <ZKDragCellTableViewDataSource, ZKDragCellTableViewDelegate>

@property (nonatomic, strong) ZKDragCellTableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ZKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self p_setupTableView];
}

- (void)p_setupTableView
{
    self.tableView = ({
        self.tableView = [[ZKDragCellTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        _tableView;
    });
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZKCell *cell = [ZKCell cellWithTableView:tableView];
    cell.model = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

/** 数据源加载 */
- (NSArray *)dataSource
{
    if (!_dataSource) {
        NSMutableArray *array = [NSMutableArray array];
        NSInteger numOfSecctions = 7;
        for (NSInteger i = 0; i < numOfSecctions; i ++) {
            UIColor *color = ZKRandomColor;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSInteger j = 0; j < 20; j ++) {
                ZKModel *model = [[ZKModel alloc] init];
                model.color = color;
                model.title = [NSString stringWithFormat:@"第%zd组-第%zd行",i,j];
                [tempArray addObject:model];
            }
            [array addObject:tempArray];
        }
        _dataSource = array;
    }
    return _dataSource;
}

// <ZKDragCellTableViewDataSource, ZKDragCellTableViewDelegate>
- (NSArray *)originalDataSourceForTableView:(ZKDragCellTableView *)tableView
{
    return _dataSource;
}

- (void)tableView:(ZKDragCellTableView *)tableView newDataSource:(NSArray *)newDataSource
{
    self.dataSource = newDataSource;
}

@end
