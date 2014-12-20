
#import "ModalTransition.h"
#import "ModalPresentationController.h"

@interface ModalTransition () {
    CGFloat panLocationStart;
    BOOL isBeingDragged;
}

@property (nonatomic, strong) UIViewController *modalController;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic) BOOL isPresenting;

@end


@implementation ModalTransition


- (instancetype)initWithModalViewController:(UIViewController *)modalViewController {
    
    self = [super init];
    if (self) {
        _modalController = modalViewController;
        _isDraggable = NO;
        isBeingDragged = NO;
    }
    return self;
}


- (void)setIsDraggable:(BOOL)isDraggable {
    _isDraggable = isDraggable;
    if (self.isDraggable) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self.modalController.view addGestureRecognizer:self.panGesture];
    }
}


#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    if (self.isPresenting) {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = self.isPresenting? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    
    // Dismissed frame = appeared frame, but off the bottom edge of the container
    CGRect dismissedFrame = appearedFrame;
    dismissedFrame.origin.y += dismissedFrame.size.height;
    
    CGRect initialFrame = self.isPresenting ? dismissedFrame : appearedFrame;
    CGRect finalFrame = self.isPresenting ? appearedFrame : dismissedFrame;
    
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
                         if (!self.isPresenting) {
                             [fromView removeFromSuperview];
                         }
                         // Notify the view controller system that the transition has finished
                        [transitionContext completeTransition:YES];
                    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.isPresenting = NO;
    self.transitionContext = nil;
}


# pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
 
    // Location reference
    CGPoint location = [recognizer locationInView:self.modalController.view.window];
    
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:self.modalController.view.window];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        isBeingDragged = YES;
        panLocationStart = location.y;
        [self.modalController dismissViewControllerAnimated:YES completion:nil];
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat animationRatio = (location.y - panLocationStart) / (CGRectGetHeight(self.modalController.presentationController.frameOfPresentedViewInContainerView));
        
        [self updateInteractiveTransition:animationRatio];
    
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        isBeingDragged = NO;
        CGFloat velocityForSelectedDirection = velocity.y;
    
        if (velocityForSelectedDirection > 300) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

#pragma mark - Interactive Transition


- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    //The presentation controller needs to know that we are dragging
    ModalPresentationController *presController = (ModalPresentationController *)[fromViewController presentationController];
    presController.dragging = YES;
    toViewController.view.transform = CGAffineTransformMakeScale(PresentingScaleFactor, PresentingScaleFactor);
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
}


- (void)updateInteractiveTransition:(CGFloat)percentComplete {
  
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    toViewController.view.transform = CGAffineTransformMakeScale(PresentingScaleFactor + ((1-PresentingScaleFactor) * percentComplete), PresentingScaleFactor + ((1-PresentingScaleFactor) * percentComplete));
    
    CGRect modalFrame = fromViewController.presentationController.frameOfPresentedViewInContainerView;
    CGFloat topMargin = modalFrame.origin.y;
   
    fromViewController.view.frame = CGRectMake(0,
                                               (topMargin + CGRectGetHeight(modalFrame) * percentComplete),
                                               CGRectGetWidth(modalFrame),
                                               CGRectGetHeight(modalFrame));
    
    //Adjust alpha of presentation controller's dimmingView
    ModalPresentationController *presController = (ModalPresentationController *)fromViewController.presentationController;
    presController.dimmingView.alpha = 1 - (topMargin/[[UIScreen mainScreen] bounds].size.height) - percentComplete;
}


- (void)finishInteractiveTransition {
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ModalPresentationController *presController = (ModalPresentationController *)fromViewController.presentationController;
    
    CGRect endRect = CGRectMake(0,
                         CGRectGetHeight(fromViewController.view.frame),
                         CGRectGetWidth(fromViewController.view.frame),
                         CGRectGetHeight(fromViewController.view.frame));

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
                         fromViewController.view.frame = endRect;
                         presController.dimmingView.alpha = 0.0;

                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         self.modalController = nil;
                     }];
    
}


- (void)cancelInteractiveTransition {
  
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ModalPresentationController *presController = (ModalPresentationController *)fromViewController.presentationController;

    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toViewController.view.transform = CGAffineTransformMakeScale(PresentingScaleFactor, PresentingScaleFactor);
                         fromViewController.view.frame = fromViewController.presentationController.frameOfPresentedViewInContainerView;
                         presController.dimmingView.alpha = 1.0;
                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:NO];
                         presController.dragging = NO;
                     }];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[ModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (ModalTransition *)animationController {
    ModalTransition *animationController = [[ModalTransition alloc] init];
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ModalTransition *animationController = [self animationController];
    animationController.isPresenting = YES;
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
   
    if (!isBeingDragged) {
        return nil;
    }
    
    ModalTransition *animationController = [self animationController];
    animationController.isPresenting = NO;
    return animationController;
}


- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return isBeingDragged ? self : nil;
}



@end

