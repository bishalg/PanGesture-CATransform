//
//  TVLeftProgressView.m
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/8/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//

#import "TVLeftProgressView.h"

@interface TVLeftProgressView()

@property (strong, nonatomic) UIView *holderView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TVLeftProgressView

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
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
    
    self.holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 28)];
    [self addSubview:self.holderView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.holderView.bounds];
    self.titleLabel.text = @"YES!";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:36];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.holderView addSubview:self.titleLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 35, 55, 55)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.holderView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint origin = CGPointMake(20 + 5 * (1 + self.progress * 0.25),
                                 20 + self.center.y * (self.progress * 0.50));
    self.holderView.frame = CGRectMake(origin.x, origin.y, 120, 60);
}

@end
