
#import "BoardView.h"
#import "GameModel.h"

extern int theme;

static int uToX[3] = {  0, 108, 216 };  // blitting positions
static int vToY[3] = { 80, 188, 296 };

#define PRESSED_ANIM_COUNT  10

static CGFloat animX[PRESSED_ANIM_COUNT];
static CGFloat animY[PRESSED_ANIM_COUNT];

@interface BoardView (Private)
- (void)initLookupTables;
- (void)loadImages;
- (void)freeImages;
- (void)drawMap;
- (void)drawPressed;
- (UIImage*)getImageFor:(int)cellType;
@end

@implementation BoardView

@synthesize backgroundImage;
@synthesize topImage;
@synthesize bottomImage;
@synthesize arrowTopLeftImage;
@synthesize arrowTopRightImage;
@synthesize arrowBottomLeftImage;
@synthesize arrowBottomRightImage;

@synthesize strokeImage1;
@synthesize crossImage1;
@synthesize fullImage1;
@synthesize strokeWinImage1;
@synthesize crossWinImage1;
@synthesize fullWinImage1;

@synthesize strokeImage2;
@synthesize crossImage2;
@synthesize fullImage2;
@synthesize strokeWinImage2;
@synthesize crossWinImage2;
@synthesize fullWinImage2;

@synthesize strokeImage3;
@synthesize crossImage3;
@synthesize fullImage3;
@synthesize strokeWinImage3;
@synthesize crossWinImage3;
@synthesize fullWinImage3;

@synthesize gameModel;

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super initWithCoder:coder])
	{
		[self initLookupTables];
		[self loadImages];
		[self resetPressedAnim];
	}
	return self;
}

- (void)initLookupTables
{
	for (int t = 0; t < PRESSED_ANIM_COUNT; ++t)
	{
		animX[t] = -4.0 * cosf(2*M_PI*t/PRESSED_ANIM_COUNT) - 11.0;
		animY[t] = animX[t] - 1.0;
	}
}

- (void)loadImages
{
	backgroundImage        = [UIImage imageNamed:@"Background.png"];
	topImage               = [UIImage imageNamed:@"Top.png"];
	bottomImage            = [UIImage imageNamed:@"Bottom.png"];
	arrowTopLeftImage      = [UIImage imageNamed:@"Arrow Top Left.png"];
	arrowTopRightImage     = [UIImage imageNamed:@"Arrow Top Right.png"];
	arrowBottomLeftImage   = [UIImage imageNamed:@"Arrow Bottom Left.png"];
	arrowBottomRightImage  = [UIImage imageNamed:@"Arrow Bottom Right.png"];
	
	strokeImage1           = [UIImage imageNamed:@"Stroke.png"];
	crossImage1            = [UIImage imageNamed:@"Cross.png"];
	fullImage1             = [UIImage imageNamed:@"Full.png"];
	strokeWinImage1        = [UIImage imageNamed:@"Stroke Win.png"];
	crossWinImage1         = [UIImage imageNamed:@"Cross Win.png"];
	fullWinImage1          = [UIImage imageNamed:@"Full Win.png"];

	strokeImage2           = [UIImage imageNamed:@"Stroke2.png"];
	crossImage2            = [UIImage imageNamed:@"Cross2.png"];
	fullImage2             = [UIImage imageNamed:@"Full2.png"];
	strokeWinImage2        = [UIImage imageNamed:@"Stroke Win2.png"];
	crossWinImage2         = [UIImage imageNamed:@"Cross Win2.png"];
	fullWinImage2          = [UIImage imageNamed:@"Full Win2.png"];
	
	strokeImage3           = [UIImage imageNamed:@"Stroke3.png"];
	crossImage3            = [UIImage imageNamed:@"Cross3.png"];
	fullImage3             = [UIImage imageNamed:@"Full3.png"];
	strokeWinImage3        = [UIImage imageNamed:@"Stroke Win3.png"];
	crossWinImage3         = [UIImage imageNamed:@"Cross Win3.png"];
	fullWinImage3          = [UIImage imageNamed:@"Full Win3.png"];
}

- (void)freeImages
{
	[backgroundImage release];
	[topImage release];
	[bottomImage release];
	[arrowTopLeftImage release];
	[arrowTopRightImage release];
	[arrowBottomLeftImage release];
	[arrowBottomRightImage release];
	
	[strokeImage1 release];
	[crossImage1 release];
	[fullImage1 release];
	[strokeWinImage1 release];
	[crossWinImage1 release];
	[fullWinImage1 release];

	[strokeImage2 release];
	[crossImage2 release];
	[fullImage2 release];
	[strokeWinImage2 release];
	[crossWinImage2 release];
	[fullWinImage2 release];
	
	[strokeImage3 release];
	[crossImage3 release];
	[fullImage3 release];
	[strokeWinImage3 release];
	[crossWinImage3 release];
	[fullWinImage3 release];
}

- (void)drawRect:(CGRect)rect
{	
	[backgroundImage drawAtPoint:(CGPointMake(0.0, 80.0))];
	[self drawMap];
	[self drawPressed];
	[topImage drawAtPoint:(CGPointMake(0.0, 0.0))];
	[bottomImage drawAtPoint:(CGPointMake(0.0, 400.0))];
}

/*
 * Draws the map into the view.
 */
- (void)drawMap
{
	for (int v = 0; v < 3; ++v)
	{
		for (int u = 0; u < 3; ++u)
		{
			int x = uToX[u];
			int y = vToY[v];

			int value = [gameModel cellValueAtV:v andU:u];
			if (value < 0)  // a winning cell
			{
				[[self getImageFor:value] drawAtPoint:CGPointMake(x, y)];
			}
			else if (value > 0)  // cell that is not empty
			{
				[[self getImageFor:value] drawAtPoint:CGPointMake(x, y)];
			}
		}
	}
}

/*
 * Draws the 'pressed' animation if the player is making a move in a cell.
 */
- (void)drawPressed
{
	if (pressedAnim != -1)
	{
		int x = uToX[gameModel.lastU];
		int y = vToY[gameModel.lastV];		
		
		[arrowTopLeftImage drawAtPoint:CGPointMake(
		   x + animX[pressedAnim], 
		   y + animY[pressedAnim])];
		
		[arrowTopRightImage drawAtPoint:CGPointMake(
			x + 104.0 - 22.0 - animX[pressedAnim], 
			y + animY[pressedAnim])];
		
		[arrowBottomLeftImage drawAtPoint:CGPointMake(
			x + animX[pressedAnim], 
			y + 104.0 - 24.0 - animY[pressedAnim])];
		
		[arrowBottomRightImage drawAtPoint:CGPointMake(
			x + 104.0 - 22.0 - animX[pressedAnim], 
			y + 104.0 - 24.0 - animY[pressedAnim])];
	}
}

/*
 * Returns the image for a particular cell type from the map.
 */
- (UIImage*)getImageFor:(int)cellType
{
	switch (theme)
	{
		case THEME_STROKES:
			switch (cellType)
			{
				case  1: return strokeImage1;
				case  2: return crossImage1;
				case  3: return fullImage1;
				case -1: return strokeWinImage1;
				case -2: return crossWinImage1;
				case -3: return fullWinImage1;
			}			
			return nil;
			
		case THEME_BUBBLES:
			switch (cellType)
			{
				case  1: return strokeImage2;
				case  2: return crossImage2;
				case  3: return fullImage2;
				case -1: return strokeWinImage2;
				case -2: return crossWinImage2;
				case -3: return fullWinImage2;
			}			
			return nil;
			
		case THEME_EGGS:
			switch (cellType)
			{
				case  1: return strokeImage3;
				case  2: return crossImage3;
				case  3: return fullImage3;
				case -1: return strokeWinImage3;
				case -2: return crossWinImage3;
				case -3: return fullWinImage3;
			}			
			return nil;
	}
	return nil;
}

/*
 * Sets the 'pressed' animation to the first frame.
 */
- (void)resetPressedAnim
{
	pressedAnim = -1;
}

/*
 * Moves the 'pressed' animation one frame forward.
 */
- (void)animatePressedSquare
{
	if (++pressedAnim == PRESSED_ANIM_COUNT)
		pressedAnim = 0;
}

- (void)dealloc
{
	[self freeImages];
	[super dealloc];
}

@end
