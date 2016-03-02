//
//  ZKDragCellTableView.m
//  ZKTableView_截图重排
//
//  Created by ZK on 16/2/15.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDragCellTableView.h"
typedef NS_ENUM(NSUInteger, snapshotMeetsEdge) {
    snapshotMeetsEdgeTop,
    snapshotMeetsEdgeBottom
};

@interface ZKDragCellTableView()

@property (nonatomic, weak) UIView *snapshot;
@property (nonatomic, strong) NSIndexPath *originalIndexPath; // 原始的位置
@property (nonatomic, strong) NSIndexPath *relocatedIndexPath; // 移动后的位置
@property (nonatomic, assign) CGPoint fingerLocation; // 手指的位置
@property (nonatomic, strong) CADisplayLink *autoScrollTimer; // 定时器 用于自动上下滑动
@property (nonatomic, assign) snapshotMeetsEdge autoScrollDirection;

@end

@implementation ZKDragCellTableView
@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}
/**
 * 处理长按事件
 */
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    UIGestureRecognizerState longPressState = longPress.state;
    _fingerLocation = [longPress locationInView:self];
    _relocatedIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
    switch (longPressState) {
        case UIGestureRecognizerStateBegan: {
            _originalIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
            if (_originalIndexPath) {
                [self cellSeletedAtIndexPath:_originalIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint center = _snapshot.center;
            center.y = _fingerLocation.y;
            _snapshot.center = center;
            if ([self checkIfSnapshotMeetsEdge]) {
                [self startAutoScrollTimer];
            }
            else {
                [self stopAutoScrollTimer];
            }
            _relocatedIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
            if (_relocatedIndexPath && ![_originalIndexPath isEqual:_relocatedIndexPath]) {
                [self cellRelocatedToNewIndexPath:_relocatedIndexPath];
            }
        }
            break;
            
        default: {// 长按手势结束或者取消, 移除截图, 显示cell
            [self stopAutoScrollTimer];
            [self didEndDraging];
        }
            break;
    }
}

#pragma mark - 私有方法

/**
 * cell被长按手指选中, 对其进行截图, 原cell隐藏
 */
- (void)cellSeletedAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    UIView *snapshot = [self customSnapshotFromView:cell];
    [self addSubview:snapshot];
    
    _snapshot = snapshot;
    cell.hidden = YES;
    CGPoint center = _snapshot.center;
    center.y = _fingerLocation.y;
    [UIView animateWithDuration:0.2 animations:^{
        _snapshot.transform = CGAffineTransformMakeScale(1.1, 1.1);
        _snapshot.alpha = 0.98;
        _snapshot.center = center;
    }];
}

- (UIView *)customSnapshotFromView:(UIView *)inputView
{
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.f;
    snapshot.layer.shadowOffset = CGSizeMake(-5.f, 0.f);
    snapshot.layer.shadowRadius = 5.f;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (BOOL)checkIfSnapshotMeetsEdge
{
    CGFloat minY = CGRectGetMinY(_snapshot.frame);
    CGFloat maxY = CGRectGetMaxY(_snapshot.frame);
    if (minY < self.contentOffset.y) {
        _autoScrollDirection = snapshotMeetsEdgeTop;
        return YES;
    }
    if (maxY > self.contentOffset.y + self.bounds.size.height) {
        _autoScrollDirection = snapshotMeetsEdgeBottom;
        return YES;
    }
    return NO;
}

- (void)startAutoScrollTimer
{
    if (_autoScrollTimer) {
        return;
    }
    _autoScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
    [_autoScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAutoScrollTimer
{
    if (!_autoScrollTimer) {
        return;
    }
    [_autoScrollTimer invalidate];
    _autoScrollTimer = nil;
}

/**
 * 开始自动滚动
 */
- (void)startAutoScroll
{
    CGFloat pixelSpeed = 4;
    if (_autoScrollDirection == snapshotMeetsEdgeTop) {
        if (self.contentOffset.y > 0) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y - pixelSpeed)];
            _snapshot.center = CGPointMake(_snapshot.center.x, _snapshot.center.y - pixelSpeed);
        }
    }
    else {
        if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y + pixelSpeed)];
            _snapshot.center = CGPointMake(_snapshot.center.x, _snapshot.center.y + pixelSpeed);
        }
    }
    
    /*  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
     */
    _relocatedIndexPath = [self indexPathForRowAtPoint:_snapshot.center];
    if (_relocatedIndexPath && ![_relocatedIndexPath isEqual:_originalIndexPath]) {
        [self cellRelocatedToNewIndexPath:_relocatedIndexPath];
    }
}

/**
 *  截图被移动到新的indexPath范围，这时先更新数据源，重排数组，再将cell移至新位置
 *  @param indexPath 新的indexPath
 */
- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath
{
    // 先更新数据源并返回给外部
    [self updateDataSource];
    // 再交换位置
    [self moveRowAtIndexPath:_originalIndexPath toIndexPath:_relocatedIndexPath];
    // 别忘更新cell的原始位置为当前的的indexPath
    _originalIndexPath = indexPath;
}

/**修改数据源，通知外部更新数据源*/
- (void)updateDataSource
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if ([self.dataSource respondsToSelector:@selector(originalDataSourceForTableView:)]) {
        [tempArray addObjectsFromArray:[self.dataSource originalDataSourceForTableView:self]];
    }
    
    if ([self nestedArrayCheck:tempArray]) { // 是嵌套数组
        if (_originalIndexPath.section == _relocatedIndexPath.section) { // 同一组
            [self moveObjectInMutableArray:tempArray[_originalIndexPath.section] fromIndex:_originalIndexPath.row toIndex:_relocatedIndexPath.row];
        }
        else {
            id originalObj = tempArray[_originalIndexPath.section][_originalIndexPath.row];
            [tempArray[_relocatedIndexPath.section] insertObject:originalObj atIndex:_relocatedIndexPath.item];
            [tempArray[_originalIndexPath.section] removeObjectAtIndex:_originalIndexPath.item];
        }
    }
    else {
        [self moveObjectInMutableArray:tempArray fromIndex:_originalIndexPath.row toIndex:_relocatedIndexPath.row];
    }
    
    // 将数组传出外部以更改数据源
    if ([self.delegate respondsToSelector:@selector(tableView:newDataSource:)]) {
        [self.delegate tableView:self newDataSource:tempArray];
    }
}

- (BOOL)nestedArrayCheck:(NSArray *)array
{
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}
/**
 * 将可变数组的一个对象移动到数组的另一个位置
 */
- (void)moveObjectInMutableArray:(NSMutableArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }
    else {
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
}

- (void)didEndDraging
{
    UITableViewCell *cell = [self cellForRowAtIndexPath:_originalIndexPath];
    cell.hidden = NO;
    cell.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _snapshot.center = cell.center;
        _snapshot.alpha = 0;
        _snapshot.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    }completion:^(BOOL finished) {
        [_snapshot removeFromSuperview];
        _snapshot = nil;
        _originalIndexPath = nil;
        _relocatedIndexPath = nil;
    }];
}

@end
