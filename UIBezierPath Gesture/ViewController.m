//
//  ViewController.m
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/6/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//
// https://www.raywenderlich.com/56885/custom-control-for-ios-tutorial-a-reusable-knob
// https://www.raywenderlich.com/86521/how-to-make-a-view-controller-transition-animation-like-in-the-ping-app
// http://www.informit.com/articles/article.aspx?p=1431312&seqNum=5

#import "ViewController.h"
#import "TVGeometry.h"

typedef CGFloat TVRotationDirection;
const TVRotationDirection TVRotationAwayFromCenter = 1.f;
const TVRotationDirection TVRotationTowardsCenter = -1.f;

typedef NS_ENUM(NSUInteger, TVSwipeDirection) {
    TVSwipeLeft,
    TVSwipeRight,
    TVSwipeUp,
    TVSwipeDown
};

@interface ViewController ()<CAAnimationDelegate>

@property (strong, nonatomic) UIView *squareView;

@property (strong, nonatomic) UIView *rightProgressView;
@property (strong, nonatomic) UIView *leftProgressView;

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) BOOL completeActionOnDragRelease;
@property (nonatomic) TVRotationDirection rotationDirection;

@property (strong, nonatomic) IBOutlet UILabel *yTranslationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *rotationValueLabel;

@property (nonatomic) TVSwipeDirection swipeDirection;
@property (strong, nonatomic) CAShapeLayer *rightMaskLayer;

@end

CGFloat yTranslationValue = 0.5;
CGFloat rotationFactor = 3.5;
BOOL returnToOrigin = YES;
CGFloat progress = 0;

@implementation ViewController

- (IBAction)yTranslationStepper:(UIStepper *)sender {
    yTranslationValue = sender.value;
    self.yTranslationValueLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
}

- (IBAction)roationFactorStepper:(UIStepper *)sender {
    rotationFactor = sender.value;
    self.rotationValueLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
}

- (IBAction)returnToOriginSwitch:(UISwitch *)sender {
    returnToOrigin = sender.isOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addGestures];
    
    _squareView = [[UIView alloc] init];
    _squareView.frame = CGRectMake(0, 0, 320, 200);
    _squareView.center = CGPointMake(self.view.center.x, self.view.center.y * 0.75);
    _squareView.backgroundColor = UIColor.redColor;
    [self.view addSubview:_squareView];
    
    [self circleForProgress:progress];
}

- (void)addGestures {
    self.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = self.squareView.center;
        // If the pan gesture originated at the top half of the view, rotate the view
        // away from the center. Otherwise, rotate towards the center.
        if ([recognizer locationInView:self.squareView].y < self.squareView.center.y) {
            self.rotationDirection = TVRotationAwayFromCenter;
        } else {
            self.rotationDirection = TVRotationTowardsCenter;
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.squareView];
        self.squareView.center = CGPointMake(self.originalCenter.x + translation.x,
                                             self.originalCenter.y + translation.y * yTranslationValue);
        [self rotateForTranslation:translation rotationDirection:self.rotationDirection];
        [self swipeDirectionForTranslation:translation];
        [self swipeProgressForTranslation:translation];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.completeActionOnDragRelease) {
            [UIView animateWithDuration:0.32
                                  delay:0.02
                 usingSpringWithDamping:0.55
                  initialSpringVelocity:0.5
                                options:UIViewAnimationOptionCurveEaseOut animations:^{
                                    self.squareView.center = self.originalCenter;
                                    self.squareView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

- (void)swipeDirectionForTranslation:(CGPoint)translation {
    if (translation.x > 0) {
        self.swipeDirection = TVSwipeRight;
        self.squareView.backgroundColor = UIColor.blueColor;
    } else {
        self.swipeDirection = TVSwipeLeft;
        self.squareView.backgroundColor = UIColor.redColor;
    }
}

- (void)swipeProgressForTranslation:(CGPoint)translation {
    progress = fabs(translation.x) / self.squareView.frame.size.width;
    NSLog(@"Progress = %f", progress);
    
    [self circleForProgress:progress];
}

- (void)rotateForTranslation:(CGPoint)translation
           rotationDirection:(TVRotationDirection)direction {
    CGFloat rotation = TVDegreesToRadians(translation.x / 100 * rotationFactor);
    self.squareView.layer.transform = CATransform3DMakeRotation(direction * rotation, 0.0, 0.0, 1.0);
}

- (void)circleForProgress:(CGFloat)progress {
    /// Creates two circular UIBezierPath instances; one is the size of the button, and the second has a radius large enough to cover the entire screen. The final animation will be between these two bezier paths.
    
    CGRect rightTopCircle = CGRectMake(CGRectGetMaxX(self.squareView.bounds) + 5,
                                       CGRectGetMinY(self.squareView.bounds)  - 5,
                                       5,
                                       5);
    UIBezierPath *rightMaskPathStart = [UIBezierPath bezierPathWithOvalInRect:rightTopCircle];
    // var extremePoint = CGPoint(x: button.center.x - 0, y: button.center.y - CGRectGetHeight(toViewController.view.bounds))
    CGPoint extremePoint = CGPointMake(self.squareView.center.x, CGRectGetMinY(self.squareView.frame));
    CGFloat radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y));
    UIBezierPath *rightMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rightTopCircle, -radius, -radius)];
    
    /// Creates a new CAShapeLayer to represent the circle mask.
    /// You assign its path value with the final circular path after the animation
    /// to avoid the layer snapping back after the animation completes.
    
    self.rightMaskLayer = [[CAShapeLayer alloc] init];
    self.rightMaskLayer.path = rightMaskPathFinal.CGPath;
    self.squareView.layer.mask = self.rightMaskLayer;

    /// Creates a CABasicAnimation on the path key path that goes from circleMaskPathInitial to circleMaskPathFinal.
    /// You also register a delegate, as you’ll do some cleanup after the animation completes.
//    CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//    maskAnimation.fromValue = (id)(rightMaskPathStart.CGPath);
//    maskAnimation.toValue = (id)(rightMaskPathFinal.CGPath);
//    maskAnimation.duration = 5.0;
//    maskAnimation.delegate = self;
    
    // [self.rightMaskLayer addAnimation:maskAnimation forKey:@"path"];
    // self.squareView.layer.mask = rightMaskPathFinal.CGPath;
}

/*
- (CAKeyframeAnimation *)rotateAnimation {
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[ @0, @0.14, @0 ];
    rotation.duration = 1.2;
    rotation.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    return rotation;
}

- (CAKeyframeAnimation *)positionRight {
    CAKeyframeAnimation *position = [CAKeyframeAnimation animation];
    position.keyPath = @"position";
    position.values = @[
                        [NSValue valueWithCGPoint:CGPointZero],
                        [NSValue valueWithCGPoint:CGPointMake(120, 50)],
                        [NSValue valueWithCGPoint:CGPointZero]
                        ];
    position.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    position.additive = YES;
    position.duration = 1.2;
    return position;
}

- (void)groupAnimation {
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @ [ [self rotateAnimation], [self positionRight] ];
    group.duration = 1.2;
    group.beginTime = 0.0;
    group.repeatCount = 1;
    
    [self.squareView.layer addAnimation:group forKey:nil];
    self.squareView.layer.speed = 0.0;
    self.squareView.layer.beginTime = 0.0;
}

- (void)circularAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 4;
    animation.repeatCount = MAXFLOAT;
    animation.path = [self drawSemiCircle].CGPath;
    animation.additive = YES;
    animation.calculationMode = kCAAnimationPaced;
    animation.rotationMode = kCAAnimationRotateAuto;
    [_squareView.layer addAnimation:animation forKey:nil];
}

- (UIBezierPath *)drawSemiCircle {
    return [UIBezierPath bezierPathWithArcCenter: self.view.center
                                          radius: 320
                                      startAngle: (M_PI + 1.1)
                                        endAngle: -(M_PI * 2 + 1.1)
                                       clockwise: YES];
}
*/

@end
