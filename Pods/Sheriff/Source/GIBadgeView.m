//
//  GIBadgeView.m
//  Sheriff
//
//  Created by Michael Amaral on 6/18/15.
//  Copyright (c) 2015 Gemr, Inc. All rights reserved.
//

#import "GIBadgeView.h"

static CGFloat const kBadgeViewMinimumSize = 20.0;
static CGFloat const kBadgeViewPadding = 5.0;
static CGFloat const kBadgeViewDefaultFontSize = 12.0;

@interface GIBadgeView ()

@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation GIBadgeView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }

    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.formatter = [NSNumberFormatter new];
    self.formatter.groupingSeparator = @",";
    self.formatter.usesGroupingSeparator = YES;

    [self setupDefaultAppearance];
}


#pragma mark - Appearance

- (void)setupDefaultAppearance {
    // Defaults for the view.
    //
    self.clipsToBounds = YES;
    self.hidden = YES;
    self.backgroundColor = [UIColor redColor];

    // Defaults for the label.
    //
    self.valueLabel = [UILabel new];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.valueLabel];

    self.textColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:kBadgeViewDefaultFontSize];
    
    // Defaults for the corner offset
    self.topOffset = 0.0f;
    self.rightOffset = 0.0f;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;

    self.valueLabel.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
    _font = font;

    self.valueLabel.font = font;
}


#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    [self layoutBadgeSubviews];
}

- (void)layoutBadgeSubviews {
    // Size our label to fit.
    //
    [self.valueLabel sizeToFit];

    // Get the height of the label - which was determined by sizeToFit.
    //
    CGFloat badgeLabelWidth = CGRectGetWidth(self.valueLabel.frame);
    CGFloat badgeLabelHeight = CGRectGetHeight(self.valueLabel.frame);

    // Calculate the height and width we will be based on the label.
    //
    CGFloat height = MAX(kBadgeViewMinimumSize, badgeLabelHeight + kBadgeViewPadding);
    CGFloat width = MAX(height, badgeLabelWidth + (2 * kBadgeViewPadding));

    // Set our frame and corner radius based on those calculations.
    //
    self.frame = CGRectMake(CGRectGetWidth(self.superview.frame) - (width / 2.0) - self.rightOffset, -(height / 2.0) + self.topOffset, width, height);
    self.layer.cornerRadius = height / 2.0;

    // Center the badge label.
    //
    self.valueLabel.frame = CGRectMake((width / 2.0) - (badgeLabelWidth / 2.0), (height / 2.0) - (badgeLabelHeight / 2.0), badgeLabelWidth, badgeLabelHeight);
}


#pragma mark - Updating the badge value

- (void)increment {
    self.badgeValue++;
}

- (void)decrement {
    self.badgeValue--;
}

- (void)setBadgeValue:(NSInteger)badgeValue {
    // No-op if we're given zero or less and our current badge value is zero,
    // meaning we're hidden anyway.
    //
    if (badgeValue <= 0 && self.badgeValue == 0) {
        return;
    }

    // If we're given a negative number and our badge value is a positive number,
    // treat this like we're setting it to zero.
    //
    if (badgeValue < 0 && self.badgeValue > 0) {
        badgeValue = 0;
    }

    // Save the new badge value now that we've sanitized it.
    //
    _badgeValue = badgeValue;

    // If the badge value is larger than zero, let's update the label. The reason
    // for this is that it looks weird when the label changes to 0 and then animates
    // away. It makes more sense for it to simply disappear.
    //
    if (badgeValue > 0) {
        self.valueLabel.text = [self.formatter stringFromNumber:@(badgeValue)];
    }

    // Update our state.
    //
    [self updateState];
}


#pragma mark - State

- (void)updateState {
    // If we're currently hidden and we should be visible, show ourself.
    //
    if (self.isHidden && self.badgeValue > 0) {
        [self layoutBadgeSubviews];
        [self show];
    }

    // Otherwise if we're visible and we shouldn't be, hide ourself.
    //
    else if (!self.isHidden && self.badgeValue <= 0) {
        [self hide];
    }

    // Otherwise update the subviews.
    //
    else {
        [self layoutBadgeSubviews];
    }
}


#pragma mark - Visibility

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

@end
