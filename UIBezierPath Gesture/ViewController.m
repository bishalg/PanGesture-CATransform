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
// Helper
#import "TVGeometry.h"
// Subview
#import "TVRightProgressView.h"
#import "TVLeftProgressView.h"

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

@property (strong, nonatomic) TVRightProgressView *rightProgressView;
@property (strong, nonatomic) TVLeftProgressView *leftProgressView;

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) BOOL completeActionOnDragRelease;
@property (nonatomic) TVRotationDirection rotationDirection;

@property (strong, nonatomic) IBOutlet UILabel *yTranslationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *rotationValueLabel;

@property (nonatomic) TVSwipeDirection swipeDirection;

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
    
    self.squareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.squareView.center = CGPointMake(self.view.center.x, self.view.center.y * 0.75);
    self.squareView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:self.squareView];
    
    self.rightProgressView = [[TVRightProgressView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.rightProgressView.frame = self.squareView.bounds;
    [self.squareView addSubview:self.rightProgressView];
    
    self.leftProgressView = [[TVLeftProgressView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.leftProgressView.frame = self.squareView.bounds;
    [self.squareView addSubview:self.leftProgressView];

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
                progress = 0;
                [self circleForProgress:0];
            } completion:nil];
        }
    }
}

- (void)swipeDirectionForTranslation:(CGPoint)translation {
    if (translation.x > 0) {
        self.swipeDirection = TVSwipeRight;
    } else {
        self.swipeDirection = TVSwipeLeft;
    }
}

- (void)swipeProgressForTranslation:(CGPoint)translation {
    progress = fabs(translation.x) / (self.squareView.frame.size.width / 2);
    [self circleForProgress:progress];
}

- (void)rotateForTranslation:(CGPoint)translation
           rotationDirection:(TVRotationDirection)direction {
    CGFloat rotation = TVDegreesToRadians(translation.x / 100 * rotationFactor);
    self.squareView.layer.transform = CATransform3DMakeRotation(direction * rotation, 0.0, 0.0, 1.0);
}

- (void)circleForProgress:(CGFloat)progress {
    /// Creates two circular UIBezierPath instances; one is the size of the button, and the second has a radius large enough to cover the entire screen. The final animation will be between these two bezier paths.
    CGPoint extremePoint = CGPointMake(self.squareView.center.x * progress, CGRectGetMinY(self.squareView.frame) * progress);
    CGFloat radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y));

    CGRect rightTopCircle = CGRectMake(CGRectGetMaxX(self.squareView.bounds) + 5,
                                       CGRectGetMinY(self.squareView.bounds)  - 5,
                                       5,
                                       5);
    UIBezierPath *rightMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rightTopCircle, -radius, -radius)];
    
    CGRect leftTopCircle = CGRectMake(CGRectGetMinX(self.squareView.bounds) - 5,
                                      CGRectGetMinY(self.squareView.bounds) - 5,
                                      5,
                                      5);
    UIBezierPath *leftMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(leftTopCircle, -radius, -radius)];
    
    /// Creates a new CAShapeLayer to represent the circle mask.
    /// You assign its path value with the final circular path after the animation
    /// to avoid the layer snapping back after the animation completes.
    
    CAShapeLayer *rightMaskLayer = [[CAShapeLayer alloc] init];
    rightMaskLayer.path = rightMaskPathFinal.CGPath;
    
    CAShapeLayer *leftMaskLayer = [[CAShapeLayer alloc] init];
    leftMaskLayer.path = leftMaskPathFinal.CGPath;
    
    if (progress == 0) {
        self.leftProgressView.layer.mask = leftMaskLayer;
        self.rightProgressView.layer.mask = rightMaskLayer;
    }  else {
        if (self.swipeDirection == TVSwipeLeft) {
            self.rightProgressView.layer.mask = rightMaskLayer;
        } else if (self.swipeDirection == TVSwipeRight) {
            self.leftProgressView.layer.mask = leftMaskLayer;
        }
    }
}

@end
