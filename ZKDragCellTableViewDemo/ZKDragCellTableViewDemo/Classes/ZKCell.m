//
//  ZKCell.m
//  ZKDragCellTableViewDemo
//
//  Created by ZK on 16/3/2.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKCell.h"
#import "ZKModel.h"

@implementation ZKCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ZKCell";
    ZKCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[ZKCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    return cell;
}

- (void)setModel:(ZKModel *)model
{
    _model = model;
    self.textLabel.text = model.title;
    self.backgroundColor = model.color;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
