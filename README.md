# ZKDragCellTableView
可以拖动cell进行重新排列, 高仿iPhone自带天气软件城市列表的拖动效果

#### 直接继承自ZKDragCellTableView, 即可实现拖动cell效果
* 需要实现下面两个方法
* 将外部的原始数据传进来`- (NSArray *)originalDataSourceForTableView:(ZKDragCellTableView *)tableView;`
* 将拖动完成后的数组传给外部`- (void)tableView:(ZKDragCellTableView *)tableView newDataSource:(NSArray *)newDataSource;`
