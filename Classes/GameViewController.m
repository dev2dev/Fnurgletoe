
#import <sys/time.h>
#import "RootViewController.h"
#import "GameViewController.h"
#import "GameOverViewController.h"
#import "BoardView.h"
#import "SoundEffect.h"

/*
 * Returns the number of milliseconds that have elapsed since system startup 
 * time as a double.
 */
double milliseconds()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

extern BOOL withSfx;

@interface GameViewController (Private)
- (void)loadSounds;
- (SoundEffect*)loadSound:(NSString*)name;
- (void)initTurn;
- (void)computerTurn;
- (void)startTimer;
- (void)stopTimer;
- (void)animateComputerPlayer;
- (void)waitForGameOver;
- (void)animatePressedSquare;
- (NSString*)getBeginMessage;
- (NSString*)getWinMessage;
- (NSString*)getWinCounts;
- (void)setMessage:(NSString*)message;
- (void)playSound:(SoundEffect*)soundEffect;
@end

@implementation GameViewController

@synthesize rootViewController;
@synthesize boardView;
@synthesize exitButton;
@synthesize undoButton;
@synthesize nextButton;
@synthesize label;
@synthesize gameModel;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		
		timer = nil;
		[self loadSounds];
	}
	return self;
}

- (void)viewDidLoad
{
	GameModel* model = [[GameModel alloc] init];
	self.gameModel = model;
	[model release];

	boardView.gameModel = gameModel;
}

- (void)loadSounds
{
	makeMoveSound     = [[self loadSound:@"Make Move"] retain];
	computerWinsSound = [[self loadSound:@"Computer Wins"] retain];
	playerWinsSound   = [[self loadSound:@"Player Wins"] retain];
	errorSound        = [[self loadSound:@"Error"] retain];
}

- (SoundEffect*)loadSound:(NSString*)name
{
	return [[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]] autorelease];
}

/*
 * Called when user switches from Intro screen to the Game screen.
 */
- (void)firstRound:(GameMode)gameMode
{
	[self startTimer];
	[gameModel initModel:gameMode];
	[self nextRound];
}

/*
 * Called at the beginning of each new round.
 */
- (void)nextRound
{
	gameOver = NO;
	[gameModel initRound];
	[self initTurn];
}

/*
 * Called for each new turn.
 */
- (void)initTurn
{
	[gameModel initTurn];

	animatePressedSquare = NO;
	[boardView resetPressedAnim];

	animateComputerPlayer = NO;
	waitForGameOver = NO;

	[boardView setNeedsDisplay];

	exitButton.enabled = YES;
	undoButton.enabled = NO;
	nextButton.enabled = NO;

	trackU = -1;
	trackV = -1;

	[self setMessage:[self getBeginMessage]];

	if ([gameModel isComputerPlayer])
		[self computerTurn];
}

/*
 * Performs the AI for the computer player.
 */
- (void)computerTurn
{
	[gameModel thinkthink];

	// Tell the timer loop that we should animate the computer's moves.
	animateComputerPlayer = YES;
	animateComputerPlayerTime = milliseconds() + 300.0;

	// Extra long delay for "no player mode", so it won't go by too fast.
	if (gameModel.gameMode == GAME_MODE_NO_PLAYERS)
		animateComputerPlayerTime += 1000.0;
}

/*
 * Called when the user clicks the 'Give Up' button.
 */
- (IBAction)exitGame
{
	[self stopTimer];

	// Remove the old game from the view before we return to the Intro screen, 
	// otherwise it will still be there when the user starts a new game. 
	// (This wouldn't be necessary if we would destroy the GameViewController 
	// instance and make a new one each time a new game is started.)
	[gameModel exitGame];	
	[boardView setNeedsDisplay];

	[rootViewController showIntro:self];
}

/*
 * Called when the user clicks the 'Undo' button.
 */
- (IBAction)undoMoves
{
	[gameModel undoMoves];
	
	animatePressedSquare = NO;
	[boardView resetPressedAnim];

	[boardView setNeedsDisplay];
	[self setMessage:@"Move undone"];

	undoButton.enabled = NO;
	nextButton.enabled = NO;
}

/*
 * Called when the user clicks the 'Next Turn' button, or when the computer
 * AI is done thinking.
 */
- (IBAction)nextTurn
{
	if ([gameModel checkWinner])
	{
		if (gameModel.gameMode == GAME_MODE_ONE_PLAYER)
		{
			if ([gameModel isComputerPlayer])
				[self playSound:computerWinsSound];
			else
				[self playSound:playerWinsSound];
		}
		else  // in any other game mode we always play the same sound
		{
			[self playSound:playerWinsSound];
		}

		gameOver = YES;

		exitButton.enabled = NO;
		undoButton.enabled = NO;
		nextButton.enabled = NO;

		animatePressedSquare = NO;
		[boardView resetPressedAnim];

		[boardView setNeedsDisplay];
		[self setMessage:@"We have a winner!"];

		// We want to wait briefly before we show the 'game over' alert,
		// so the player can clearly see what the winning move was. 
		waitForGameOver = YES;
		waitForGameOverTime = milliseconds() + 1500.0;
	}
	else
	{
		[self initTurn];
	}
}

/*
 * Starts the timer loop.
 */
- (void)startTimer
{
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.1  // 100 ms
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
}

/*
 * Kills the timer loop.
 */
- (void)stopTimer
{
	if (timer != nil && [timer isValid])
	{
		[timer invalidate];
		timer = nil;
	}
}

/*
 * The timer loop. It runs continuously while the Game screen is active. This
 * is where we handle animations and user interface delays.
 */
- (void)handleTimer:(NSTimer*)timer
{
	if (animateComputerPlayer)
		[self animateComputerPlayer];
	
	if (waitForGameOver)
		[self waitForGameOver];
	
	if (animatePressedSquare)
		[self animatePressedSquare];
}

/*
 * Performs the animation of the computer making a move.
 */
- (void)animateComputerPlayer
{
	double now = milliseconds();
	if (now >= animateComputerPlayerTime)
	{		
		if ([gameModel performComputerMove])
		{
			[boardView setNeedsDisplay];
			[self playSound:makeMoveSound];
			animateComputerPlayerTime = now + 50.0;
		}
		else
		{
			animateComputerPlayer = NO;
			[self nextTurn];		
		}
	}
}

/*
 * Displays an animation on the square where the player has made a move.
 */
- (void)animatePressedSquare
{
	[boardView animatePressedSquare];
	[boardView setNeedsDisplay];
}

/*
 * Displays the 'game over' pop-up box after a small delay.
 */
- (void)waitForGameOver
{
	if (milliseconds() >= waitForGameOverTime)
	{
		gameOverViewController = [[GameOverViewController alloc] initWithNibName:@"GameOverView" bundle:nil];
		gameOverViewController.gameViewController = self;
		gameOverViewController.view.center = self.view.center;
		gameOverViewController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
		gameOverViewController.titleLabel.text = [self getWinMessage];
		gameOverViewController.messageView.text = [self getWinCounts];
		
		[gameOverViewController viewWillAppear:YES];
		[self.view addSubview:gameOverViewController.view];
		[gameOverViewController viewDidAppear:YES];

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
		gameOverViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		[UIView commitAnimations];

		// Note: the code continues here while the game over box is still being 
		// shown. We have to wait until the box closes before we start a new 
		// game round. This happens in the function gameOverScreenDidExit:.
		
		waitForGameOver = NO;
	}
}

/*
 * Called when the 'game over' pop-up box has grown to its full size.
 */
- (void)growAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
	// do nothing
}

/*
 * We get here when the user closes the 'game over' pop-up box.
 */
- (void)gameOverScreenDidExit
{
	[gameOverViewController viewWillDisappear:YES];
	[gameOverViewController.view removeFromSuperview];
	[gameOverViewController viewDidDisappear:YES];
	[gameOverViewController release];

	[self nextRound];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	if ([gameModel isComputerPlayer] || gameOver)
		return;

	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView:boardView];
	
	int u, v;
	[gameModel cellCoordsAtX:location.x andY:location.y toU:&u andV:&v];
	
	if (u != -1 && v != -1)
	{
		trackU = u;
		trackV = v;
	}
	else
	{
		trackU = -1;
		trackV = -1;
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	if ([gameModel isComputerPlayer] || gameOver)
		return;

	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView:boardView];

	int u, v;
	[gameModel cellCoordsAtX:location.x andY:location.y toU:&u andV:&v];
	
	// outside the map, or source and destination cells are not the same
	if (trackU == -1 || u != trackU || v != trackV)
		return;

	trackU = -1;
	trackV = -1;
	
	if (!gameModel.hasMadeMove)  // can still place anywhere
	{
		gameModel.lastU = u;
		gameModel.lastV = v;
		gameModel.lastValue = [gameModel cellValueAtV:v andU:u];
	}
	else if (gameModel.lastU != u || gameModel.lastV != v)  // can only place 
	{                                                       // at (v,u) now
		[self setMessage:@"You may change only one square"];
		[self playSound:errorSound];
		return;
	}
	
	if ([gameModel canUpgradeCellAtV:v andU:u])
	{
		if (!gameModel.hasMadeMove)
		{
			animatePressedSquare = YES;
			[boardView animatePressedSquare];  // first frame
		}

		[gameModel upgradeCellAtV:v andU:u];
		[boardView setNeedsDisplay];
		[self playSound:makeMoveSound];
		[self setMessage:@""];
		undoButton.enabled = YES;
		nextButton.enabled = YES;
	}
	else if (!gameModel.hasMadeMove)
	{
		[self setMessage:@"Move not possible here"];
		[self playSound:errorSound];
	}
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
	if ([gameModel isComputerPlayer] || gameOver)
		return;

	trackU = -1;
	trackV = -1;
}

/*
 * Returns the text for the label at the beginning of a new round or turn.
 */
- (NSString*)getBeginMessage
{
	if (gameModel.gameMode != GAME_MODE_ONE_PLAYER)
	{
		if ([gameModel activePlayer] == 0)
		{
			if ([gameModel turnCount] == 0)
				return @"Player ONE begins...";
			else
				return @"Player ONE's turn...";
		}
		else
		{
			if ([gameModel turnCount] == 0)
				return @"Player TWO begins...";
			else
				return @"Player TWO's turn...";
		}
	}
	else  // single-player mode
	{
		if ([gameModel isComputerPlayer])
		{
			if ([gameModel turnCount] == 0)
				return @"iPhone begins...";
			else
				return @"iPhone's turn...";
		}
		else
		{
			if ([gameModel turnCount] == 0)
				return @"You begin... Make your move!";
			else
				return @"Your turn... Make your move!";
		}
	}
}

/*
 * Returns the title text for the alert at the end of a round.
 */
- (NSString*)getWinMessage
{
	if (gameModel.gameMode != GAME_MODE_ONE_PLAYER)
	{
		if ([gameModel activePlayer] == 0)
			return @"Player ONE WINS!";
		else
			return @"Player TWO WINS!";
	}
	else  // single-player mode
	{
		if ([gameModel isComputerPlayer])
			return @"iPhone WINS!";
		else
			return @"YOU WIN!";
	}
}

/*
 * Returns the body text for the alert at the end of a round.
 */
- (NSString*)getWinCounts
{
	NSString* format = nil;
	if (gameModel.gameMode != GAME_MODE_ONE_PLAYER)
		format = @"Player ONE: %d\nPlayer TWO: %d";
	else
		format = @"You: %d\niPhone: %d";
	
	return [NSString stringWithFormat:format, [gameModel winCount:0], [gameModel winCount:1]];
}

/*
 * Displays the specified message in the text label.
 */
- (void)setMessage:(NSString*)message
{
	label.text = message;
}

/*
 * Plays the sound effect if sound effects are enabled.
 */
- (void)playSound:(SoundEffect*)soundEffect
{
	if (withSfx)
		[soundEffect play];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[self stopTimer];
	[gameModel release];

	[boardView release];
	[exitButton release];
	[undoButton release];
	[nextButton release];
	[label release];

	[makeMoveSound release];
	[computerWinsSound release];
	[playerWinsSound release];
	[errorSound release];
	
	[super dealloc];
}

@end
