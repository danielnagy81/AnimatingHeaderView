//
//  AnimatingHeaderImage.swift
//  MovingImageTest
//
//  Created by Daniel_Nagy on 21/04/16.
//  Copyright © 2016 NDani. All rights reserved.
//

import UIKit

enum AnimatingHeaderImageAnimationType {
    case TopToBottom
    case ZoomIn
}

class AnimatingHeaderImage: UIView {
    
    let images: [UIImage]
    
    var fadeTime: NSTimeInterval = 2
    var animationTime: NSTimeInterval = 30
    
    var animationType = AnimatingHeaderImageAnimationType.TopToBottom
    var restartAfterFinish = true
    
    private var currentImageIndex: Int = 0
    private var fadeView = UIView()
    private var imageView = UIImageView()
    
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    convenience init(image: UIImage, fadeView: UIView? = nil) {
        self.init(images: [image], fadeView: fadeView)
    }
    
    init(images: [UIImage], fadeView: UIView? = nil) {
        
        guard images.count > 0 else {
            fatalError("Initializing \(AnimatingHeaderImage.self) with empty array!")
        }
        self.images = images
        
        super.init(frame: CGRectZero)
        
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        setupImageView()
        setupFadeView(fadeView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) IS DEALLOCATED!")
    }
}

//MARK: Setup methods
extension AnimatingHeaderImage {
    
    private func setupImageView() {
        imageView.image = images.first
        imageView.contentMode = .Center
        
        addSubview(imageView)
    }
    
    private func setupFadeView(fadeView: UIView?) {
        
        if let fadeView = fadeView {
            self.fadeView = fadeView
        } else {
            self.fadeView.backgroundColor = UIColor.blackColor()
        }
        addSubview(self.fadeView)
        setupFadeViewConstraints()
    }
    
    private func setupFadeViewConstraints() {
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fadeView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        fadeView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        fadeView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        fadeView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageViewTopConstraint == nil {
            setupImageViewConstraints()
            
            if animationType == .TopToBottom {
                imageViewTopConstraint.constant = 0
                imageViewLeadingConstraint.constant = (frame.width - images[currentImageIndex].size.width) / 2
            }
        }
    }
    
    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewLeadingConstraint = imageView.leadingAnchor.constraintEqualToAnchor(leadingAnchor)
        imageViewTopConstraint = imageView.topAnchor.constraintEqualToAnchor(topAnchor)
        imageViewWidthConstraint = imageView.widthAnchor.constraintEqualToConstant(images[currentImageIndex].size.width)
        imageViewHeightConstraint = imageView.heightAnchor.constraintEqualToConstant(images[currentImageIndex].size.height)
        
        imageViewLeadingConstraint.active = true
        imageViewTopConstraint.active = true
        imageViewWidthConstraint.active = true
        imageViewHeightConstraint.active = true
    }
}

//MARK: Animations
extension AnimatingHeaderImage {
    
    func startImageAnimation() {
        
        switch animationType {
            
        case .TopToBottom:
            imageVerticalMovementAnimation()
        case .ZoomIn:
            zoomAnimation()
        }
    }
    
    private func imageVerticalMovementAnimation() {
        let topConstraintGoalConstant = frame.height - images[currentImageIndex].size.height
        let topConstraintGoalDuringFadeOut = CGFloat(fadeTime / animationTime) * topConstraintGoalConstant
        
        imageViewTopConstraint.constant = topConstraintGoalDuringFadeOut
        
        UIView.animateWithDuration(fadeTime, delay: 0, options: .CurveLinear, animations: { [weak self] in
            
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
            
            self?.fadeView.alpha = 0
            
            }) { [weak self] _ in
                
                self?.imageViewTopConstraint.constant = topConstraintGoalConstant
                
                guard let animationTime = self?.animationTime, fadeTime = self?.fadeTime else {
                    return
                }
                
                UIView.animateWithDuration(animationTime - fadeTime, delay: 0, options: .CurveLinear, animations: {
                    
                    self?.setNeedsLayout()
                    self?.layoutIfNeeded()
                    }, completion: nil)
                
                UIView.animateWithDuration(fadeTime, delay: animationTime - 2 * fadeTime, options: .CurveEaseInOut, animations: {
                    
                    self?.fadeView.alpha = 1
                    
                    }, completion: { _ in
                        self?.imageViewTopConstraint.constant = 0
                        
                        self?.setNeedsLayout()
                        self?.layoutIfNeeded()
                        self?.changeToNextImageIfNeeded()
                        self?.imageVerticalMovementAnimation()
                })
        }
    }
    
    private func zoomAnimation() {
        let zoomMaximumValue: CGFloat = 1.2
        let fadeTimeToAnimationRatio = CGFloat(fadeTime / animationTime)
        let fadePartZoomValue = (zoomMaximumValue - 1) * fadeTimeToAnimationRatio + 1
        
        UIView.animateWithDuration(fadeTime, delay: 0, options: .CurveLinear, animations: { [weak self] in
            
            self?.fadeView.alpha = 0
            self?.imageView.transform = CGAffineTransformMakeScale(fadePartZoomValue, fadePartZoomValue)
            
            }) { [weak self] _ in
                
                guard let animationTime = self?.animationTime, fadeTime = self?.fadeTime else {
                    return
                }
                
                UIView.animateWithDuration(animationTime - fadeTime, delay: 0, options: .CurveLinear, animations: { 
                    
                    self?.imageView.transform = CGAffineTransformMakeScale(zoomMaximumValue, zoomMaximumValue)
                    
                    }, completion: nil)
                UIView.animateWithDuration(fadeTime, delay: animationTime - 2 * fadeTime, options: .CurveEaseInOut, animations: {
                    
                    self?.fadeView.alpha = 1
                    
                    }, completion: { _ in
                        self?.imageView.transform = CGAffineTransformIdentity
                        
                        self?.changeToNextImageIfNeeded()
                        self?.zoomAnimation()
                })
        }
    }
    
    private func changeToNextImageIfNeeded() {
        
        guard images.count > 1 else {
            return
        }
        currentImageIndex = (currentImageIndex + 1) % images.count
        imageView.image = images[currentImageIndex]
        
        setupNextImageConstraints()
    }
    
    private func setupNextImageConstraints() {
        imageViewWidthConstraint.constant = images[currentImageIndex].size.width
        imageViewHeightConstraint.constant = images[currentImageIndex].size.height
        
        if animationType == .TopToBottom {
            imageViewTopConstraint.constant = 0
            imageViewLeadingConstraint.constant = (frame.width - images[currentImageIndex].size.width) / 2
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}
