//
//  TVGeometry.m
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/7/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//

#import "TVGeometry.h"

@implementation TVGeometry

CGPoint TVCGPointAdd(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x + b.x,
                       a.y + b.y);
}

CGPoint TVCGPointSubtract(const CGPoint minuend, const CGPoint subtrahend) {
    return CGPointMake(minuend.x - subtrahend.x,
                       minuend.y - subtrahend.y);
}

CGFloat TVDegreesToRadians(const CGFloat degrees) {
    return degrees * (M_PI/180.0);
}

@end
