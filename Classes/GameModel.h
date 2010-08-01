
/* Describes how many players will be playing the game. */
typedef enum
{
	GAME_MODE_ONE_PLAYER = 0,   // single-player game
	GAME_MODE_TWO_PLAYERS,      // two-player game
	GAME_MODE_NO_PLAYERS,       // computer vs. computer
}
GameMode;

/* Describes the tap-able area of a cell. */
typedef struct
{
	int x1, y1;  // top-left corner
	int x2, y2;  // bottom-right corner
}
CellRect;

/* The visual theme. */
typedef enum
{
	THEME_BUBBLES = 0,
	THEME_STROKES,
	THEME_EGGS,
	NUM_THEMES,
}
Theme;

/*
 * The data model for the game.
 *
 * Keeps track of the contents of the "map" (the 3x3 cells), and what the 
 * active player is doing.
 *
 * The terminology used:
 *   round: a single game from beginning to end, starting with an empty screen
 *          and ending with one of the players making 3-in-a-row
 *   turn:  players take turns in the round
 *   move:  a single upgrade of a cell; a turn consists of one or more moves 
 *          by one player
 */
@interface GameModel : NSObject
{
	// Possible values: 0 = empty, 1 = stroke /, 2 = cross X, 3 = full O.
	// At the end of a round, the value of winning cells is negated so we
	// can draw stars on them.
	int map[3][3];

	// Coordinates and cell value for undo (human player only).
	int lastU;
	int lastV;
	int lastValue;

	// For the AI routines (computer player only).
	int compU;
	int compV;
	int compValue;

	// Whether the player already made a move this turn.
	BOOL hasMadeMove;
	
	// The player currently taking a turn (0 or 1). In single-player mode, 
	// player 0 is the human and player 1 is the computer.
	int activePlayer;

	// How many turns have been taken in this round.
	int turnCount;

	// How many rounds have been played so far.
	int roundCount;

	// How many rounds each player won.
	int wins[2];

	// Whether the players are humans or computer-controlled.
	GameMode gameMode;
}

@property (nonatomic, assign) int lastU;
@property (nonatomic, assign) int lastV;
@property (nonatomic, assign) int lastValue;
@property (nonatomic, assign) BOOL hasMadeMove;
@property (nonatomic, assign) int activePlayer;
@property (nonatomic, assign) int turnCount;
@property (nonatomic, assign) int roundCount;
@property (nonatomic, assign) GameMode gameMode;

- (void)initModel:(GameMode)gameMode;
- (void)initRound;
- (void)initTurn;
- (void)cellCoordsAtX:(CGFloat)x andY:(CGFloat)y toU:(int*)outU andV:(int*)outV;
- (int)cellValueAtV:(int)v andU:(int)u;
- (BOOL)canUpgradeCellAtV:(int)v andU:(int)u;
- (void)upgradeCellAtV:(int)v andU:(int)u;
- (void)undoMoves;
- (BOOL)checkWinner;
- (int)winCount:(int)player;
- (BOOL)isComputerPlayer;
- (void)thinkthink;
- (BOOL)performComputerMove;
- (void)exitGame;

@end
