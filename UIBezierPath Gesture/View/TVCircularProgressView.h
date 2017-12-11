//
//  TVCircularProgressView.h
//
//  Created by Bishal Ghimire on 12/4/17.
//

#import <UIKit/UIKit.h>

@interface TVCircularProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) UIColor *strokeColor;

- (void)startAnimation;

@end
