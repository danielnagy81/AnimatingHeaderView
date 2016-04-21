//
//  MovingImageView.h
//  MovingImageTest
//
//  Created by Daniel_Nagy on 19/04/16.
//  Copyright © 2016 NDani. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, MovingImageViewImageAnimationType) {
   TopToBottom = 0,
   ZoomIn
};

@interface MovingImageView : UIView

@property (nonatomic) NSTimeInterval fadeTime;
@property (nonatomic) MovingImageViewImageAnimationType animationType;
@property (nonatomic) BOOL restartAfterFinish;
@property (nonatomic) NSTimeInterval animationTime;

@property (nonatomic) NSArray <UIImage *> * _Nonnull images;

- (instancetype _Nullable)initWithImage:(UIImage * _Nonnull)image;
- (instancetype _Nullable)initWithImage:(UIImage * _Nonnull)image withFadeView:(UIView * _Nullable)fadeView;
- (instancetype _Nullable)initWithImages:(NSArray <UIImage *> * _Nonnull)images;
- (instancetype _Nullable)initWithImages:(NSArray <UIImage *> * _Nonnull)images withFadeView:(UIView * _Nullable)fadeView;

- (void)startImageAnimation;

@end
