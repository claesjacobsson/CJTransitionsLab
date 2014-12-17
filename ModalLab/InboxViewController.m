
#import "InboxViewController.h"
#import "MailViewController.h"

#import "OverlayTransitioner.h"
//#import "Transition.h"

@interface InboxViewController () {
// Transition *transitionManager;
}

//@property (nonatomic, strong) Transition *transitionManager;

@end

@implementation InboxViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
      //  _transitionManager = [[OverlayAnimatedTransitioning alloc] init];
      //  self.transitioningDelegate = self.transitionManager;
       // self.transitioningDelegate = [[OverlayAnimatedTransitioning alloc] init];
        //self.transitioningDelegate = self.transitionManager;
        
    }
    return self;
}

- (void)viewDidLoad {
   // self.transitionManager = [[OverlayAnimatedTransitioning alloc] init];
    self.transitioningDelegate = [[OverlayTransitioningDelegate alloc] init];
}


- (IBAction)newMail:(id)sender {
    [self performSegueWithIdentifier:@"NewMail" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NewMail"]) {
        MailViewController *mailVC = segue.destinationViewController;
        //mailVC.transitionManager = self.transitionManager;
        //mailVC.transitioningDelegate = self.transitionManager;
        [mailVC setTransitioningDelegate:[self transitioningDelegate]];
    }

}

@end
