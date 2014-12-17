
@import UIKit;

//@interface OverlayAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
//
//@property (nonatomic) BOOL isPresentation;
//
//@end

@interface OverlayAnimatedTransitioning : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic) BOOL isPresentation;
@property (nonatomic, readwrite) id <UIViewControllerContextTransitioning> transitionContext;


- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration;
- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration;

@end


@interface OverlayTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>
@end