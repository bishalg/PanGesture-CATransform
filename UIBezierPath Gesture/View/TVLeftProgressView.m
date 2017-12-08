//
//  TVLeftProgressView.m
//  UIBezierPath Gesture
//
//  Created by Bishal Ghimire on 12/8/17.
//  Copyright © 2017 Bishal Ghimire. All rights reserved.
//

#import "TVLeftProgressView.h"

@interface TVLeftProgressView()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation TVLeftProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.frame];
    self.titleLabel.text = @"  YES";
    self.titleLabel.textAlignment = NSTextAlignmentLeft;;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.center = self.center;
}

@end
