
@import UIKit;

@interface ModalTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isDraggable;

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController;

@end

