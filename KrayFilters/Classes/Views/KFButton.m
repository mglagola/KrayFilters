//
//  KFButton.m
//  KrayFilters
//
//  Created by Mark Glagola on 5/26/13.
//  Copyright (c) 2013 Mark Glagola. All rights reserved.
//

#import "KFButton.h"

@interface KFButton () {
    BOOL isScaled;
}

@end

@implementation KFButton

- (void) setDefaults {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = [UIDevice isIPAD] ? 1.0f : 0.5f;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setDefaults];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaults];
    }
    return self;
}

- (id) init {
    return [self initWithFrame:CGRectZero];
}

- (void) setHighlighted: (BOOL) highlighted {
    [super setHighlighted: highlighted];
    
    BOOL highlightedWithoutScale = highlighted && !isScaled;
    BOOL scaledWithoutHighlight = !highlighted && isScaled;
    if (highlightedWithoutScale || scaledWithoutHighlight) {
        isScaled = highlightedWithoutScale ? YES : NO;
        [self animateLayerWithScaleAnimationSpeed:5 ascending:isScaled];
    }
}

- (void) animateLayerWithScaleAnimationSpeed:(float)speed ascending:(BOOL)ascending
{
    CGFloat startScale = [[self.layer valueForKeyPath:@"transform.scale"] floatValue];
    CGFloat finalScale = ascending ? 1.15f : 1.0f;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:startScale];
    animation.toValue = [NSNumber numberWithFloat:finalScale];
    animation.speed = speed;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.layer addAnimation:animation forKey:@"Scale Animation"];
}

@end
