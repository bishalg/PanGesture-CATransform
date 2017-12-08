//
//  TVGeometry.h
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/7/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//

@import UIKit;

@interface TVGeometry : NSObject

extern CGPoint TVCGPointAdd(const CGPoint a, const CGPoint b);
extern CGPoint TVCGPointSubtract(const CGPoint minuend, const CGPoint subtrahend);
extern CGFloat TVDegreesToRadians(const CGFloat degrees);

@end
