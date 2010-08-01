
#import "GameOverViewController.h"
#import "GameViewController.h"

@implementation GameOverViewController

@synthesize gameViewController;
@synthesize okButton;
@synthesize titleLabel;
@synthesize messageView;

- (IBAction)exitScreen
{
	[gameViewController gameOverScreenDidExit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[messageView release];
	[titleLabel release];
	[okButton release];
	[super dealloc];
}

@end
