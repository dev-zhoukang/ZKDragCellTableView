//
//  UIView+ZK_Add.m
//  ZKDragCellTableViewDemo
//
//  Created by Zhou Kang on 2017/11/22.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import "UIView+ZK_Add.h"

@implementation UIView (ZK_Add)

- (UIView *)zK_customSnapshot {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = self.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.f;
    snapshot.layer.shadowOffset = CGSizeMake(-5.f, 0.f);
    snapshot.layer.shadowRadius = 5.f;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
