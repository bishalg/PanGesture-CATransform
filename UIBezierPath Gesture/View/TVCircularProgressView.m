//
//  TVCircularProgressView.m
//
//  Created by Bishal Ghimire on 12/4/17.
//
// https://stackoverflow.com/a/15323712/1294448

#import "TVCircularProgressView.h"

@interface TVCircularProgressView()

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (strong, nonatomic) CAShapeLayer *pathLayer;

@end

@implementation TVCircularProgressView

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // Determine our start and stop angles for the arc (in radians)
        self.startAngle = M_PI * 1.5;
        self.endAngle = self.startAngle + (M_PI * 2);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.progress > 100) {
        self.progress = 100;
    }
    UIBezierPath *bezierPath = [self arcPathForProgress:self.progress];
    [self.strokeColor setStroke];
    [self.pathLayer setPath:bezierPath.CGPath];
    [bezierPath stroke];
}

- (UIBezierPath *)arcPathForProgress:(CGFloat)progress {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
                          radius:self.frame.size.width / 2 - 1
                      startAngle:self.startAngle
                        endAngle:(self.endAngle - self.startAngle) * (progress / 100.0) + self.startAngle
                       clockwise:YES];
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 2;
    return bezierPath;
}

- (void)startAnimation {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[self arcPathForProgress:100] CGPath];
    shapeLayer.strokeColor = [self.strokeColor CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 1.5f;
    shapeLayer.lineJoin = kCALineJoinBevel;
    [self.layer addSublayer:shapeLayer];
    
    self.pathLayer = shapeLayer;
    
    CABasicAnimation *animateStrokEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokEnd.duration = 0.5;
    animateStrokEnd.fromValue = @(0.0);
    animateStrokEnd.toValue = @(1.0);

    [self.pathLayer addAnimation:animateStrokEnd forKey:@"strokeEnd"];
}

@end
