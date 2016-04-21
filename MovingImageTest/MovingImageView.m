//
//  MovingImageView.m
//  MovingImageTest
//
//  Created by Daniel_Nagy on 19/04/16.
//  Copyright © 2016 NDani. All rights reserved.
//

#import "MovingImageView.h"

@implementation MovingImageView {
    
    NSUInteger _currentImageIndex;
    
    UIView *_fadeView;
    UIImageView *_imageView;
    
    NSLayoutConstraint *_imageViewTopConstraint;
    NSLayoutConstraint *_imageViewLeadingConstraint;
    NSLayoutConstraint *_imageViewWidthConstraint;
    NSLayoutConstraint *_imageViewHeightConstraint;
}

- (instancetype _Nullable)initWithImage:(UIImage * _Nonnull)image {
    return [self initWithImage:image withFadeView:nil];
}

- (instancetype _Nullable)initWithImage:(UIImage * _Nonnull)image withFadeView:(UIView * _Nullable)fadeView {
    return [self initWithImages:@[image] withFadeView:fadeView];
}

- (instancetype _Nullable)initWithImages:(NSArray <UIImage *> * _Nonnull)images {
    return [self initWithImages:images withFadeView:nil];
}

- (instancetype _Nullable)initWithImages:(NSArray <UIImage *> * _Nonnull)images withFadeView:(UIView * _Nullable)fadeView {
    self = [super init];
    if (self) {
        _images = images;
        _restartAfterFinish = YES;
        _fadeTime = 2.0;
        
        [self setClipsToBounds:YES];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setupImageView];
        [self setupFadeViewWithFadeView:fadeView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_imageViewTopConstraint) {
        [self setupImageViewConstraints];
        
        if (self.animationType == TopToBottom) {
            _imageViewTopConstraint.constant = 0.0f;
            _imageViewLeadingConstraint.constant = (self.frame.size.width - self.images[_currentImageIndex].size.width) / 2.0f;
        }
    }
}

- (void)setupImageViewConstraints {
    
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _imageViewTopConstraint = [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor];
    _imageViewLeadingConstraint = [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    _imageViewWidthConstraint = [_imageView.widthAnchor constraintEqualToConstant:_images[_currentImageIndex].size.width];
    _imageViewHeightConstraint = [_imageView.heightAnchor constraintEqualToConstant:_images[_currentImageIndex].size.height];
    
    [_imageViewTopConstraint setActive:YES];
    [_imageViewLeadingConstraint setActive:YES];
    [_imageViewWidthConstraint setActive:YES];
    [_imageViewHeightConstraint setActive:YES];
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] init];
    _imageView.image = [_images firstObject];
    _imageView.contentMode = UIViewContentModeCenter;
    
    [self addSubview:_imageView];
}

- (void)setupFadeViewWithFadeView:(UIView * _Nullable)fadeView {
    
    if (fadeView) {
        _fadeView = fadeView;
    } else {
        _fadeView = [[UIView alloc] init];
        _fadeView.backgroundColor = [UIColor blackColor];
    }
    [self addSubview:_fadeView];
    [self setupFadeViewConstraints];
}

- (void)setupFadeViewConstraints {
    [_fadeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_fadeView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_fadeView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_fadeView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_fadeView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
}

- (void)startImageAnimation {
    
    if (self.animationType == TopToBottom) {
        [self imageVerticalMovementAnimation];
        
    } else if (self.animationType == ZoomIn) {
        [self zoomAnimation];
    } else {
        [NSException raise:@"Unknown animation type" format:@"The animation type supplied for \"animationType\" is unknown"];
    }
}

- (void)imageVerticalMovementAnimation {
    
    CGFloat topConstraintGoalConstant = self.frame.size.height - self.images[_currentImageIndex].size.height;
    
    __weak MovingImageView *weakSelf = self;
    
    CGFloat topConstraintMovementDuringFadeOut = (CGFloat)(self.fadeTime / self.animationTime) * topConstraintGoalConstant;
    
    _imageViewTopConstraint.constant = topConstraintMovementDuringFadeOut;
    
    [UIView animateWithDuration:self.fadeTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        [weakSelf setNeedsLayout];
        [weakSelf layoutIfNeeded];
    
        MovingImageView *strongSelf = weakSelf;
        
        if (strongSelf) {
            strongSelf->_fadeView.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
        _imageViewTopConstraint.constant = topConstraintGoalConstant;
        
        [UIView animateWithDuration:self.animationTime - self.fadeTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            [weakSelf setNeedsLayout];
            [weakSelf layoutIfNeeded];
            
        } completion:nil];
        
        [UIView animateWithDuration:self.fadeTime delay:self.animationTime - 2.0 * self.fadeTime options:UIViewAnimationOptionCurveEaseInOut animations:^{
            MovingImageView *strongSelf = weakSelf;
            
            if (strongSelf) {
                strongSelf->_fadeView.alpha = 1.0f;
            }
        } completion:^(BOOL finished) {
            
            if (weakSelf.restartAfterFinish) {
                MovingImageView *strongSelf = weakSelf;
                
                if (strongSelf) {
                    strongSelf->_imageViewTopConstraint.constant = 0.0f;
                    [strongSelf setNeedsLayout];
                    [strongSelf layoutIfNeeded];
                }
                [weakSelf changeToNextImageIfNeeded];
                [weakSelf imageVerticalMovementAnimation];
            }
        }];
    }];
}

- (void)zoomAnimation {
    
    CGFloat zoomMaximumValue = 1.2f;
    CGFloat fadeTimeToAnimationRatio = self.fadeTime / self.animationTime;
    CGFloat fadePartZoomValue = (zoomMaximumValue - 1) * fadeTimeToAnimationRatio + 1;
    
    __weak MovingImageView *weakSelf = self;
    
    [UIView animateWithDuration:self.fadeTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        _fadeView.alpha = 0.0f;
        _imageView.transform = CGAffineTransformMakeScale(fadePartZoomValue, fadePartZoomValue);
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            [UIView animateWithDuration:self.animationTime - self.fadeTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                
                _imageView.transform = CGAffineTransformMakeScale(zoomMaximumValue, zoomMaximumValue);
            } completion:^(BOOL finished) {
                
            }];
            
            [UIView animateWithDuration:self.fadeTime delay:self.animationTime - 2.0 * self.fadeTime options:UIViewAnimationOptionCurveEaseInOut animations:^{
                MovingImageView *strongSelf = weakSelf;
                
                if (strongSelf) {
                    strongSelf->_fadeView.alpha = 1.0f;
                }
            } completion:^(BOOL finished) {
                
                if (weakSelf.restartAfterFinish) {
                    MovingImageView *strongSelf = weakSelf;
                    
                    if (strongSelf) {
                        strongSelf->_imageView.transform = CGAffineTransformIdentity;
                        
                        [strongSelf changeToNextImageIfNeeded];
                        [strongSelf zoomAnimation];
                    }
                }
            }];
        }
    }];
}

- (void)changeToNextImageIfNeeded {
    
    _currentImageIndex = (_currentImageIndex + 1) % self.images.count;
    _imageView.image = self.images[_currentImageIndex];
    
    [self setupNextImageConstraints];
}

- (void)setupNextImageConstraints {
    _imageViewWidthConstraint.constant = self.images[_currentImageIndex].size.width;
    _imageViewHeightConstraint.constant = self.images[_currentImageIndex].size.height;
    
    if (self.animationType == TopToBottom) {
        _imageViewTopConstraint.constant = 0.0f;
        _imageViewLeadingConstraint.constant = (self.frame.size.width - self.images[_currentImageIndex].size.width) / 2.0f;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)dealloc {
    NSLog(@"%@ IS DEALLOCATED!", self);
}

@end
