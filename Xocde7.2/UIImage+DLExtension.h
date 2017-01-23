//
//  UIImage+DLExtension.h
//  LNG Shop
//
//  Created by Ernie Liu on 16/5/13.
//  Copyright © 2016年 Ernie Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DLExtension)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
