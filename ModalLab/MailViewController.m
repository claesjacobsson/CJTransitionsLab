
#import "MailViewController.h"
//#import "Transition.h"
#import "OverlayTransitioner.h"

@interface MailViewController ()

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@end

@implementation MailViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.navBar addGestureRecognizer:pan];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)pan:(UIPanGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        [self dismissViewControllerAnimated:YES completion:NULL];
        [recognizer setTranslation:CGPointZero inView:self.view.superview];
        [self.transitionManager updateInteractiveTransition:0];
       // [transitionManager updateInteractiveTransition:0];
        return;
    }
    
    CGFloat percentage = [recognizer translationInView:self.view.superview].y/self.view.superview.bounds.size.height;
    
    [self.transitionManager updateInteractiveTransition:percentage];
    
    if (recognizer.state==UIGestureRecognizerStateEnded) {
        
        CGFloat velocityY = [recognizer velocityInView:recognizer.view.superview].y;
        BOOL cancel = (velocityY < 0) || (velocityY == 0 && recognizer.view.frame.origin.y < self.view.superview.bounds.size.height/2);
        CGFloat points = cancel ? recognizer.view.frame.origin.y : self.view.superview.bounds.size.height - recognizer.view.frame.origin.y;
        NSTimeInterval duration = points / velocityY;
        
        if (duration < .2) {
            duration = .2;
        } else if(duration > .6) {
            duration = .6;
        }
        
        cancel ? [self.transitionManager cancelInteractiveTransitionWithDuration:duration] : [self.transitionManager finishInteractiveTransitionWithDuration:duration];
        
    } else if (recognizer.state==UIGestureRecognizerStateFailed){
        
        [self.transitionManager cancelInteractiveTransitionWithDuration:.35];
        
    }
    
}
                                              


@end
