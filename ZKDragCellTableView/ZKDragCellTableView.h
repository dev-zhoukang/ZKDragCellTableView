//
//  ZKDragCellTableView.h
//  ZKTableView_截图重排
//
//  Created by ZK on 16/2/15.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZKDragCellTableView;

@protocol ZKDragCellTableViewDataSource <UITableViewDataSource>
@required
/**获取外部的原始的数据源*/
- (NSArray *)originalDataSourceForTableView:(ZKDragCellTableView *)tableView;
@end

@protocol ZKDragCellTableViewDelegate <UITableViewDelegate>
@required
/**将重新排序的数据源传到外部*/
- (void)tableView:(ZKDragCellTableView *)tableView newDataSource:(NSArray *)newDataSource;
@optional
- (void)tableView:(ZKDragCellTableView *)tableView cellReadyToMoveAtIndexPath:(NSIndexPath *)indexPath;
- (void)cellIsMovingInTableView:(ZKDragCellTableView *)tableView;
- (void)cellDidEndMovingInTableView:(ZKDragCellTableView *)tableView;
@end

@interface ZKDragCellTableView : UITableView

@property (nonatomic, weak) id <ZKDragCellTableViewDataSource> dataSource;
@property (nonatomic, weak) id <ZKDragCellTableViewDelegate> delegate;
@end
