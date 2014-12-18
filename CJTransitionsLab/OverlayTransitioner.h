
@import UIKit;


@interface OverlayAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL isPresenting;

@end


@interface OverlayTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end