
#import "GameModel.h"

static CellRect cellRects[3][3] =
{
	{
		{   0,  80, 105, 185 },  // [0][0]
		{ 106,  80, 213, 185 },  // [1][0]
		{ 214,  80, 319, 185 },  // [2][0]
	},
	{
		{   0, 186, 105, 293 },  // [0][1]
		{ 106, 186, 213, 293 },  // [1][1]
		{ 214, 186, 319, 293 },  // [2][1]
	},
	{
		{   0, 294, 105, 399 },  // [0][2]
		{ 106, 294, 213, 399 },  // [1][2]
		{ 214, 294, 319, 399 },  // [2][2]
	},
};

@interface GameModel (Private)
- (void)resetMap;
- (void)resetPlayer;
- (BOOL)findBestMove;
- (void)randomize:(int*) table;
- (BOOL)canWin;
@end

@implementation GameModel

@synthesize lastU;
@synthesize lastV;
@synthesize lastValue;
@synthesize hasMadeMove;
@synthesize activePlayer;
@synthesize turnCount;
@synthesize roundCount;
@synthesize gameMode;

/*
 * Makes sure the map is empty, because the view is painted at least once
 * before [initModel] is called.
 */
- (id)init
{
	if ((self = [super init]))
	{
		[self resetMap];
		[self resetPlayer];
	}
	return self;
}

/*
 * Called when the user goes from the Intro screen to the Game screen.
 */
- (void)initModel:(GameMode)gameMode_
{
	gameMode = gameMode_;
	roundCount = -1;
	wins[0] = 0;
	wins[1] = 0;

	srand(time(NULL));
}

/*
 * Called when a new round starts.
 */
- (void)initRound
{
	++roundCount;
	activePlayer = 1 - (roundCount % 2);
	turnCount = -1;
	[self resetMap];
}

/*
 * Called when a new turn starts.
 */
- (void)initTurn
{
	activePlayer = 1 - activePlayer;
	++turnCount;
	[self resetPlayer];
}

/*
 * Clears the map.
 */
- (void)resetMap
{
	for (int v = 0; v < 3; ++v)
		for (int u = 0; u < 3; ++u)
			map[v][u] = 0;
}

/*
 * Clears the state variables for the active player.
 */
- (void)resetPlayer
{
	lastU = -1;
	lastV = -1;
	lastValue = 0;
	hasMadeMove = NO;
}

/*
 * Converts a touch coordinate into a cell column number (0..2) and cell row
 * number (0..2). Sets the row and/or column to -1 if the touch was outside 
 * the playing area.
 */
- (void)cellCoordsAtX:(CGFloat)x andY:(CGFloat)y toU:(int*)outU andV:(int*)outV;
{
	for (int v = 0; v < 3; ++v)
	{
		for (int u = 0; u < 3; ++u)
		{
			if (x >= cellRects[v][u].x1 
			&&  x <= cellRects[v][u].x2
			&&  y >= cellRects[v][u].y1
			&&  y <= cellRects[v][u].y2)
			{
				*outU = u;
				*outV = v;
				return;
			}
		}
	}
	
	*outU = -1;
	*outV = -1;
}

/*
 * Returns the value of the cell at coordinates (v,u).
 */
- (int)cellValueAtV:(int)v andU:(int)u
{
	return map[v][u];
}

/*
 * Determines whether the cell at the specified coordinates can still
 * be upgraded.
 */
- (BOOL)canUpgradeCellAtV:(int)v andU:(int)u
{
	return map[v][u] < 3;
}

/*
 * Upgrades the cell at the specified coordinates.
 */
- (void)upgradeCellAtV:(int)v andU:(int)u
{
	map[v][u]++;
	hasMadeMove = YES;
}

/*
 * Restores the map to the state it was in before this turn.
 */
- (void)undoMoves
{
	map[lastV][lastU] = lastValue;
	[self resetPlayer];
}

/*
 * Determines if the active player has made a winning move.
 */
- (BOOL)checkWinner
{
	if (map[0][0] > 0 && map[0][0] == map[0][1] && map[0][1] == map[0][2])
	{
		map[0][0] *= -1;  // make winning squares
		map[0][1] *= -1;  // negative for drawing
		map[0][2] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[1][0] > 0 && map[1][0] == map[1][1] && map[1][1] == map[1][2])
	{
		map[1][0] *= -1;
		map[1][1] *= -1;
		map[1][2] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[2][0] > 0 && map[2][0] == map[2][1] && map[2][1] == map[2][2])
	{
		map[2][0] *= -1;
		map[2][1] *= -1;
		map[2][2] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[0][0] > 0 && map[0][0] == map[1][0] && map[1][0] == map[2][0])
	{
		map[0][0] *= -1;
		map[1][0] *= -1;
		map[2][0] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[0][1] > 0 && map[0][1] == map[1][1] && map[1][1] == map[2][1])
	{
		map[0][1] *= -1;
		map[1][1] *= -1;
		map[2][1] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[0][2] > 0 && map[0][2] == map[1][2] && map[1][2] == map[2][2])
	{
		map[0][2] *= -1;
		map[1][2] *= -1;
		map[2][2] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[0][0] > 0 && map[0][0] == map[1][1] && map[1][1] == map[2][2])
	{
		map[0][0] *= -1;
		map[1][1] *= -1;
		map[2][2] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	if (map[0][2] > 0 && map[0][2] == map[1][1] && map[1][1] == map[2][0])
	{
		map[0][2] *= -1;
		map[1][1] *= -1;
		map[2][0] *= -1;
		wins[activePlayer]++;
		return YES;
	}

	return NO;
}

/*
 * Returns the number of rounds the specified player has won.
 */
- (int)winCount:(int)player
{
	return wins[player];
}

/*
 * Determines whether the active player is computer-controlled.
 */
- (BOOL)isComputerPlayer
{
	if (gameMode == GAME_MODE_NO_PLAYERS)
		return true;
	
	if (gameMode == GAME_MODE_TWO_PLAYERS)
		return false;
	
	return activePlayer == 1;
}

/*
 * Performs the computer AI.
 */
- (void)thinkthink
{
	compU = -1;
	compV = -1;
	compValue = -1;
	
	if (turnCount == 0)
	{
		compU     = rand() % 3;      // if computer makes the
		compV     = rand() % 3;      // first move in the round,
		compValue = rand() % 3 + 1;  // it's always random
		return;
	}
	
	if ([self canWin])  // can we fill in a winning row?
		return;

	if (![self findBestMove])  // if we can't make a good move,
	{                          // then pick one at random
		do
		{
			compU = rand() % 3;
			compV = rand() % 3;
		}
		while (map[compV][compU] == 3);
		
		compValue = map[compV][compU] + 1;
	}
}

/*
 * Look at every square in a random order; if we find a move that doesn't give 
 * the other player the opportunity to make a winning row, we take it. 
 *
 * The computer always plays a perfect game: it will make moves without losing 
 * as long as such moves are available. The random element is simply there to 
 * make the computer player more interesting to watch, so it doesn't always do 
 * the same.
 */
- (BOOL)findBestMove
{
	int randV[3]  = { 0, 0, 0 };
	int randU[3]  = { 0, 0, 0 };
	int values[3] = { 0, 0, 0 };

	[self randomize:randV];
	[self randomize:randU];
	[self randomize:values];

	for (int vv = 0; vv < 3; ++vv)
	{
		for (int uu = 0; uu < 3; ++uu)
		{
			int v = randV[vv];  // look at a random cell
			int u = randU[uu];

			if (map[v][u] < 3)  // can still make a move here?
			{
				for (int t = 0; t < 3; ++t)      // try /, X, O in random order
				{
					int value = values[t] + 1;
					if (map[v][u] < value)       // can make this move?
					{
						int mapOld = map[v][u];  // can other player win now?
						map[v][u] = value;
						BOOL goodMove = ![self canWin];
						map[v][u] = mapOld;

						if (goodMove)
						{
							compU = u;
							compV = v;
							compValue = value;
							return YES;
						}
					}
				}
			}
		}
	}
	
	return NO;
}

/*
 * Puts the values 0, 1, 2 in random order in the lookup table.
 */
- (void)randomize:(int*) table
{
	switch (rand() % 6)  // there are 6 possible combinations
	{
		case 0: table[0] = 0; table[1] = 1; table[2] = 2; break;  //012
		case 1: table[0] = 0; table[1] = 2; table[2] = 1; break;  //021
		case 2: table[0] = 1; table[1] = 0; table[2] = 2; break;  //102
		case 3: table[0] = 1; table[1] = 2; table[2] = 0; break;  //120
		case 4: table[0] = 2; table[1] = 0; table[2] = 1; break;  //201
		case 5: table[0] = 2; table[1] = 1; table[2] = 0; break;  //210
	}		

	// This is the method the original Java implementation used:
	//table[0] = rand() % 3;
	//while (table[1] == table[0]) table[1] = rand() % 3;
	//table[2] = 3 - (table[0] + table[1]);
}

/*
 * Can we fill up a winning row? Requirement: there are two squares of the 
 * same value in the row and the third is less. For example: X X O is no good, 
 * but X X / and X X . are.
 */
- (BOOL)canWin
{
	for (int v = 0; v < 3; ++v)
	{
		if (map[v][0] == map[v][1] && map[v][2] < map[v][0])
		{
			compU = 2;
			compV = v;
			compValue = map[v][0];
			return YES;
		}
		
		if (map[v][0] == map[v][2] && map[v][1] < map[v][0])
		{
			compU = 1;
			compV = v;
			compValue = map[v][2];
			return YES;
		}
		
		if (map[v][1] == map[v][2] && map[v][0] < map[v][1])
		{
			compU = 0;
			compV = v;
			compValue = map[v][1];
			return YES;
		}
	}
	
	for (int u = 0; u < 3; ++u)
	{
		if (map[0][u] == map[1][u] && map[2][u] < map[0][u])
		{
			compU = u;
			compV = 2;
			compValue = map[0][u];
			return YES;
		}
		
		if (map[0][u] == map[2][u] && map[1][u] < map[0][u])
		{
			compU = u;
			compV = 1;
			compValue = map[2][u];
			return YES;
		}
		
		if (map[1][u] == map[2][u] && map[0][u] < map[1][u])
		{
			compU = u;
			compV = 0;
			compValue = map[1][u];
			return YES;
		}
	}
	
	if (map[0][0] == map[1][1] && map[2][2] < map[0][0])
	{
		compU = 2;
		compV = 2;
		compValue = map[0][0];
		return YES;
	}
	
	if (map[0][0] == map[2][2] && map[1][1] < map[0][0])
	{
		compU = 1;
		compV = 1;
		compValue = map[2][2];
		return YES;
	}
	
	if (map[1][1] == map[2][2] && map[0][0] < map[1][1])
	{
		compU = 0;
		compV = 0;
		compValue = map[1][1];
		return YES;
	}
	
	if (map[2][0] == map[1][1] && map[0][2] < map[2][0])
	{
		compU = 2;
		compV = 0;
		compValue = map[2][0];
		return YES;
	}
	
	if (map[2][0] == map[0][2] && map[1][1] < map[2][0])
	{
		compU = 1;
		compV = 1;
		compValue = map[0][2];
		return YES;
	}
	
	if (map[1][1] == map[0][2] && map[2][0] < map[1][1])
	{
		compU = 0;
		compV = 2;
		compValue = map[1][1];
		return YES;
	}
	
	return NO;
}

/*
 * The computer doesn't set the cell to the new value immediately. Using this
 * we simulate it clicking the cell several times.
 *
 * Returns NO if there are no more moves, i.e. the cell is at the target value.
 */
- (BOOL)performComputerMove
{
	if (map[compV][compU] == compValue)
		return NO;

	map[compV][compU]++;
	return YES;
}

/*
 * For switching back from Game screen to Intro.
 */
- (void)exitGame
{
	[self resetMap];
}

@end
