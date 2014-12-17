
#import "OverlayPresentationController.h"
#import "OverlayTransitioner.h"


@implementation OverlayPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        [self prepareDimmingView];
    }
    
    return self;
}

- (void)presentationTransitionWillBegin {
    
    // Here, we'll set ourselves up for the presentation

    UIView *containerView = [self containerView];
    UIViewController *presentedViewController = [self presentedViewController];
    UIViewController *presentingViewController = [self presentingViewController];

    // Make sure the dimming view is the size of the container's bounds, and fully transparent

    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];

    // Insert the dimming view below everything else

    [containerView insertSubview:[self dimmingView] atIndex:0];
    
    // Presenting VC (Inbox) offset and scaling
    CGAffineTransform offSetTransform = CGAffineTransformMakeTranslation(0, 0);
    offSetTransform = CGAffineTransformScale(offSetTransform, 0.9, 0.9);
    
    if ([presentedViewController transitionCoordinator]) {
        [[presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

            // Fade the dimming view to be fully visible
            [[self dimmingView] setAlpha:1.0];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            // Scale down inbox
            presentingViewController.view.transform = offSetTransform;
        } completion:nil];
    
    } else {
        [[self dimmingView] setAlpha:1.0];
    }
}

- (void)dismissalTransitionWillBegin {
    
    UIViewController *presentingViewController = [self presentingViewController];

    // Presenting VC (Inbox) offset and scaling
    CGAffineTransform offSetTransform = CGAffineTransformMakeTranslation(0, 0);
    offSetTransform = CGAffineTransformScale(offSetTransform, 1.0, 1.0);
    
    // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent

    if ([[self presentedViewController] transitionCoordinator]) {
        [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [[self dimmingView] setAlpha:0.0];
            presentingViewController.view.transform = offSetTransform;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        } completion:nil];
    
    } else {
        [[self dimmingView] setAlpha:0.0];
        presentingViewController.view.transform = offSetTransform;
    }
}

- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    
    return CGSizeMake(floorf(parentSize.width),
                      parentSize.height - ModalViewDistanceFromTop);
}

- (void)containerViewWillLayoutSubviews {
    
    // Before layout, make sure our dimmingView and presentedView have the correct frame
    [[self dimmingView] setFrame:[[self containerView] bounds]];
    [[self presentedView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (BOOL)shouldPresentInFullscreen {
    // This is a full screen presentation
    return YES;
}

- (CGRect)frameOfPresentedViewInContainerView {
    // Return a rect with the same size as -sizeForChildContentContainer:withParentContainerSize:, and right aligned
    CGRect presentedViewFrame = CGRectZero;
    CGRect containerBounds = [[self containerView] bounds];
    
    presentedViewFrame.size = [self sizeForChildContentContainer:(UIViewController<UIContentContainer> *)[self presentedViewController]
                                         withParentContainerSize:containerBounds.size];
    
    presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height;
    
    return presentedViewFrame;
}

- (void)prepareDimmingView {
    _dimmingView = [[UIView alloc] init];
    [[self dimmingView] setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
    [[self dimmingView] setAlpha:0.0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
    [[self dimmingView] addGestureRecognizer:tap];
}

- (void)dimmingViewTapped:(UIGestureRecognizer *)gesture {
    if([gesture state] == UIGestureRecognizerStateRecognized) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
