
@class GameViewController;

/*
 * This is the 'Player X Wins!' box that appears on top of the game screen
 * after a round completes.
 */
@interface GameOverViewController : UIViewController
{
	GameViewController* gameViewController;
	UIButton* okButton;
	UILabel* titleLabel;
	UITextView* messageView;
}

@property (nonatomic, assign) GameViewController* gameViewController;
@property (nonatomic, retain) IBOutlet UIButton* okButton;	
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;	
@property (nonatomic, retain) IBOutlet UITextView* messageView;	

- (IBAction)exitScreen;

@end
