
#import "OverlayTransitioner.h"
#import "OverlayPresentationController.h"


@implementation OverlayTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[OverlayPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (OverlayAnimatedTransitioning *)animationController {
    OverlayAnimatedTransitioning *animationController = [[OverlayAnimatedTransitioning alloc] init];
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    OverlayAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresenting:YES];
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    OverlayAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresenting:NO];
    return animationController;
}

@end


@implementation OverlayAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresenting = [self isPresenting];

    if (isPresenting) {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresenting? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    
    // Dismissed frame = appeared frame, but off the bottom edge of the container
    CGRect dismissedFrame = appearedFrame;
    dismissedFrame.origin.y += dismissedFrame.size.height;
    
    CGRect initialFrame = isPresenting ? dismissedFrame : appearedFrame;
    CGRect finalFrame = isPresenting ? appearedFrame : dismissedFrame;
    
    [animatingView setFrame:initialFrame];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setFrame:finalFrame];
                    }
                     completion:^(BOOL finished){
                         if (![self isPresenting]) {
                             [fromView removeFromSuperview];
                         }
                         // Notify the view controller system that the transition has finished
                        [transitionContext completeTransition:YES];
                    }];
}


@end

