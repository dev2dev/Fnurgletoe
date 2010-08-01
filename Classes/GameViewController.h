
#import "GameModel.h"

@class RootViewController;
@class BoardView;
@class SoundEffect;
@class GameOverViewController;

/*
 * The controller performs most of the game logic. Here we also handle the 
 * touches on BoardView.
 */
@interface GameViewController : UIViewController
{
	RootViewController* rootViewController;
	GameOverViewController* gameOverViewController;

	BoardView* boardView;	
	UIButton* exitButton;
	UIButton* undoButton;
	UIButton* nextButton;	
	UILabel* label;

	GameModel* gameModel;  // we own the model

	// For keeping track of which cell the active player first touched. 
	// A move is only valid if the touch begins and ends in the same cell.
	int trackU;
	int trackV;

	BOOL gameOver;  // true after round is complete

	// We use a timer for animations and other stuff that needs to happen
	// after a delay, such as showing the 'game over' alert box.
	NSTimer* timer;
	BOOL animateComputerPlayer;
	double animateComputerPlayerTime;	
	BOOL animatePressedSquare;
	BOOL waitForGameOver;
	double waitForGameOverTime;

	SoundEffect* makeMoveSound;
	SoundEffect* computerWinsSound;
	SoundEffect* playerWinsSound;
	SoundEffect* errorSound;
}

@property (nonatomic, assign) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet BoardView* boardView;	
@property (nonatomic, retain) IBOutlet UIButton* exitButton;	
@property (nonatomic, retain) IBOutlet UIButton* undoButton;	
@property (nonatomic, retain) IBOutlet UIButton* nextButton;
@property (nonatomic, retain) IBOutlet UILabel* label;
@property (nonatomic, retain) GameModel* gameModel;

- (void)firstRound:(GameMode)gameMode;
- (void)nextRound;
- (IBAction)exitGame;
- (IBAction)undoMoves;
- (IBAction)nextTurn;
- (void)gameOverScreenDidExit;

@end
