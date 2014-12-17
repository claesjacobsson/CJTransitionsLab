
#import "OverlayTransitioner.h"
#import "OverlayPresentationController.h"

//#import "InboxViewController.h"

@interface OverlayAnimatedTransitioning ()

//@property (nonatomic, readwrite) id <UIViewControllerContextTransitioning> transitionContext;

@end



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


- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}


- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    return nil;   //Returns default animator
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
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
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


#pragma mark - UIViewControllerInteractiveTransitioning
/*
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.transitionContext = transitionContext;
    
    UIView *inView = [transitionContext containerView];
   // UINavigationController *toNavController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
   // UIViewController *toViewController = toNavController.topViewController;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSLog(@"to: %@", toViewController);
    NSLog(@"from: %@", fromViewController);
   
    
    //toViewController.view.transform=CGAffineTransformMakeScale(1, 1);
    //fromViewController.view.transform=CGAffineTransformMakeScale(1, 1);
    //toViewController.view.alpha=0;
    [inView addSubview:toViewController.view];
    CGRect frame = toViewController.view.frame;
   //  frame.origin.y = inView.bounds.size.height;
    toViewController.view.frame = frame;
    //toViewController.view.alpha=1;
}

#pragma mark - UIPercentDrivenInteractiveTransition

- (void)updateInteractiveTransition:(CGFloat)percentComplete{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (percentComplete < 0) {
        percentComplete = 0;
    } else if (percentComplete > 1){
        percentComplete=1;
    }
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSLog(@"to: %@", toViewController);
    NSLog(@"from: %@", fromViewController);
    
    
    CGFloat scale = 1 - (1-0.7) * percentComplete;
    
    CGRect frame = toViewController.view.frame;
    frame.origin.y = toViewController.view.bounds.size.height * percentComplete -toViewController.view.bounds.size.height;
    toViewController.view.frame=frame;
    fromViewController.view.transform=CGAffineTransformMakeScale(scale,scale);
    
 
}

- (void)cancelInteractiveTransitionWithDuration:(CGFloat)duration{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromViewController.view.transform=CGAffineTransformMakeScale(1, 1);
                         CGRect frame=toViewController.view.frame;
                         frame.origin.y=-toViewController.view.bounds.size.height;
                         toViewController.view.frame=frame;
                     } completion:^(BOOL finished) {
                         [toViewController.view removeFromSuperview];
                         [self.transitionContext cancelInteractiveTransition];
                         [self.transitionContext completeTransition:NO];
                         self.transitionContext=nil;
                     }];
    
    
    [self cancelInteractiveTransition];
}

- (void)finishInteractiveTransitionWithDuration:(CGFloat)duration{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromViewController.view.transform=CGAffineTransformMakeScale(.7, .7);
                         CGRect frame=toViewController.view.frame;
                         frame.origin.y=0;
                         toViewController.view.frame=frame;
                     } completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [self.transitionContext completeTransition:YES];
                         self.transitionContext=nil;
                     }];
    
    [self finishInteractiveTransition];
}


*/

@end

