//
//  TVRightProgressView.m
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/8/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//

#import "TVRightProgressView.h"

@interface TVRightProgressView()

@property (strong, nonatomic) UIView *holderView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TVRightProgressView

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    
    self.holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 28)];
    [self addSubview:self.holderView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.holderView.bounds];
    self.titleLabel.text = @"NO!";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:36];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.holderView addSubview:self.titleLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.holderView.frame.size.width - 60, 45, 55, 55)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.holderView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint origin = CGPointMake(self.center.x - 5 * (1 + self.progress * 0.25),
                                 20 + 5 * (1 + self.progress * 0.75));
    self.holderView.frame = CGRectMake(origin.x, origin.y, 120, 60);
}

@end
