
@import UIKit;

extern CGFloat const PresentingScaleFactor;     // Scale factor of presenting view
extern CGFloat const PresentingVisiblePoints;   // Visible part of presenting view

@interface ModalPresentationController : UIPresentationController

@property (nonatomic) UIView *dimmingView;
@property (nonatomic) BOOL dragging;

- (CGRect)frameOfPresentedViewInContainerView;

@end
