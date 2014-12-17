//
//  Transition.h
//  ModalLab
//
//  Created by Claes Jacobsson on 2014-12-17.
//  Copyright (c) 2014 Demo. All rights reserved.
//

@import UIKit;

@interface Transition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, readwrite) id <UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic) BOOL isPresentation;

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration;
- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration;

@end
