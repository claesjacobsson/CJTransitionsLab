
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
    [animationController setIsPresentation:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    OverlayAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresentation:NO];
    
    return animationController;
}


@end


@implementation OverlayAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    // Here, we perform the animations necessary for the transition

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];

    if (isPresentation) {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    appearedFrame = CGRectMake(appearedFrame.origin.x, appearedFrame.origin.y + ModalViewDistanceFromTop, appearedFrame.size.width, appearedFrame.size.height - ModalViewDistanceFromTop);
    
    // Our dismissed frame is the same as our appeared frame, but off the right edge of the container
    CGRect dismissedFrame = appearedFrame;
    dismissedFrame.origin.y += dismissedFrame.size.height;
    
    
    CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
    CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
    
    [animatingView setFrame:initialFrame];
    
    // Animate using the duration from -transitionDuration:
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setFrame:finalFrame];
                    }
                     completion:^(BOOL finished){
                        // If we're dismissing, remove the presented view from the hierarchy
                         if (![self isPresentation]) {
                             [fromView removeFromSuperview];
                         }
                         // We need to notify the view controller system that the transition has finished
                        [transitionContext completeTransition:YES];
                    }];
}


@end

