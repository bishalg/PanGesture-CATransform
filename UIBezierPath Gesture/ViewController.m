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
#import "TVCircularProgressView.h"

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
@property (strong, nonatomic) TVCircularProgressView *circularProgressView;

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) BOOL completeActionOnDragRelease;

@property (nonatomic) TVRotationDirection rotationDirection;
@property (nonatomic) TVSwipeDirection swipeDirection;

@property (strong, nonatomic) UILabel *bgRateLabel;
@property (strong, nonatomic) UIButton *circularButton;

@property (strong, nonatomic) IBOutlet UILabel *yTranslationValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *rotationValueLabel;

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
    
    CGFloat size = 60;
    self.circularButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.circularButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.circularButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.circularButton.frame = CGRectMake(self.view.center.x - size / 2, 500, size, size);
    self.circularButton.layer.cornerRadius = size / 2;
    [self.view addSubview:self.circularButton];
    
    self.circularProgressView = [[TVCircularProgressView alloc] initWithFrame:self.circularButton.bounds];
    self.circularProgressView.strokeColor = [UIColor redColor];
    self.circularProgressView.userInteractionEnabled = NO;
    [self.circularButton addSubview:self.circularProgressView];
    
    self.squareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.squareView.center = CGPointMake(self.view.center.x, self.view.center.y * 0.75);
    self.squareView.backgroundColor = UIColor.grayColor;
    self.squareView.layer.shouldRasterize = YES;
    [self.view addSubview:self.squareView];
    
    self.rightProgressView = [[TVRightProgressView alloc] initWithFrame:self.squareView.bounds];
    [self.squareView addSubview:self.rightProgressView];
    
    self.leftProgressView = [[TVLeftProgressView alloc] initWithFrame:self.squareView.bounds];
    [self.squareView addSubview:self.leftProgressView];
    
    self.bgRateLabel = [[UILabel alloc] initWithFrame:self.squareView.frame];
    self.bgRateLabel.font = [UIFont systemFontOfSize:25];
    self.bgRateLabel.numberOfLines = 2;
    self.bgRateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.bgRateLabel];
    [self.view bringSubviewToFront:self.squareView];

    [self circleForProgress:progress];
}

- (void)buttonAction:(UIButton *)button {
    [self.circularProgressView startAnimation];
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
        if (self.completeActionOnDragRelease) {
             if (self.swipeDirection == TVSwipeLeft) {
                 [UIView animateWithDuration:0.15 animations:^{
                     self.squareView.frame = CGRectOffset(self.squareView.frame, -500, 400);
                 }];
             } else if (self.swipeDirection == TVSwipeRight) {
                 [UIView animateWithDuration:0.15 animations:^{
                     self.squareView.frame = CGRectOffset(self.squareView.frame, 500, 400);
                 }];
             }
        } else {
            [UIView animateWithDuration:0.32
                                  delay:0.02
                 usingSpringWithDamping:0.55
                  initialSpringVelocity:0.5
            options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.squareView.center = self.originalCenter;
                self.squareView.transform = CGAffineTransformIdentity;
                progress = 0;
                [self circleForProgress:0];
                self.circularProgressView.progress = progress * 0;
            } completion:nil];
        }
    }
}

- (void)swipeDirectionForTranslation:(CGPoint)translation {
    if (translation.x > 0) {
        self.swipeDirection = TVSwipeRight;
        self.bgRateLabel.textColor = UIColor.blueColor;
    } else {
        self.swipeDirection = TVSwipeLeft;
        self.bgRateLabel.textColor = UIColor.redColor;
    }
    self.bgRateLabel.text = [self textForDirection:self.swipeDirection];
}

- (NSString *)textForDirection:(TVSwipeDirection)direction {
    if (self.swipeDirection == TVSwipeRight) {
        return @"I want to \nwatch this";
    } else if (self.swipeDirection == TVSwipeLeft) {
        return @"I don't want \nto watch this";
    }
    return @"";
}

- (void)swipeProgressForTranslation:(CGPoint)translation {
    progress = fabs(translation.x) / (self.squareView.frame.size.width / 2);
    if (progress >= 0.95) {
        self.completeActionOnDragRelease = YES;
    } else {
        self.completeActionOnDragRelease = NO;
    }
    if (progress > 1) {
        progress = 1;
    }
    self.circularProgressView.progress = progress * 100;
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

    CGFloat size = 5;
    CGFloat yPt = CGRectGetMinY(self.squareView.bounds) - size;
    CGFloat rightX = CGRectGetMaxX(self.squareView.bounds) + size;
    CGFloat leftX = CGRectGetMinX(self.squareView.bounds) - size;
    CGRect rightTopCircle = CGRectMake(rightX, yPt, size, size);
    CGRect leftTopCircle = CGRectMake(leftX, yPt, size, size);
    
    UIBezierPath *rightMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rightTopCircle, -radius, -radius)];
    UIBezierPath *leftMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(leftTopCircle, -radius, -radius)];
    
    /// Creates a new CAShapeLayer to represent the circle mask.
    /// You assign its path value with the final circular path after the animation
    /// to avoid the layer snapping back after the animation completes.
    
    CAShapeLayer *rightMaskLayer = [[CAShapeLayer alloc] init];
    rightMaskLayer.path = rightMaskPathFinal.CGPath;
    
    CAShapeLayer *leftMaskLayer = [[CAShapeLayer alloc] init];
    leftMaskLayer.path = leftMaskPathFinal.CGPath;
    
    /// For Initial Case Mask Both the layer out !
    if (progress == 0) {
        self.leftProgressView.layer.mask = leftMaskLayer;
        self.rightProgressView.layer.mask = rightMaskLayer;
    }  else {
        if (self.swipeDirection == TVSwipeLeft) {
            self.rightProgressView.layer.mask = rightMaskLayer;
            self.rightProgressView.progress = progress;
        } else if (self.swipeDirection == TVSwipeRight) {
            self.leftProgressView.layer.mask = leftMaskLayer;
            self.leftProgressView.progress = progress;
        }
    }
}

@end
