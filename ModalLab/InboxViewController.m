
#import "InboxViewController.h"
#import "MailViewController.h"

#import "OverlayTransitioner.h"

@interface InboxViewController () {
// Transition *transitionManager;
}

//@property (nonatomic, strong) Transition *transitionManager;

@end

@implementation InboxViewController


- (IBAction)newMail:(id)sender {
    [self performSegueWithIdentifier:@"NewMail" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NewMail"]) {
        
       self.transitioningDelegate = [[OverlayTransitioningDelegate alloc] init];
        MailViewController *mailVC = segue.destinationViewController;
        //mailVC.transitionManager = self.transitionManager;
        //mailVC.transitioningDelegate = self.transitionManager;
        [mailVC setTransitioningDelegate:[self transitioningDelegate]];
    }

}

@end
