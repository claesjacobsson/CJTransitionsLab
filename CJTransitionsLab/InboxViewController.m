
#import "InboxViewController.h"
#import "MailViewController.h"

#import "ModalTransition.h"


@interface InboxViewController ()
@property (nonatomic, strong) ModalTransition *animator;
@end


@implementation InboxViewController


- (IBAction)newMail:(id)sender {
    [self performSegueWithIdentifier:@"NewMail" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NewMail"]) {

        MailViewController *mailVC = segue.destinationViewController;
        self.animator = [[ModalTransition alloc] initWithModalViewController:mailVC];
        self.animator.isDraggable = YES;
        mailVC.transitioningDelegate = self.animator;
    }
}

@end
