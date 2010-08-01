
#import "GameModel.h"

/*
 * BoardView draws the playing area.
 *
 * We simply draw all the sprites as UIImage objects into our own view.
 */
@interface BoardView : UIView
{
	UIImage* backgroundImage;
	UIImage* topImage;
	UIImage* bottomImage;
	UIImage* arrowTopLeftImage;
	UIImage* arrowTopRightImage;
	UIImage* arrowBottomLeftImage;
	UIImage* arrowBottomRightImage;
	
	UIImage* strokeImage1;  // /
	UIImage* crossImage1;   // X
	UIImage* fullImage1;    // O
	UIImage* strokeWinImage1;
	UIImage* crossWinImage1;
	UIImage* fullWinImage1;

	UIImage* strokeImage2;
	UIImage* crossImage2;
	UIImage* fullImage2;
	UIImage* strokeWinImage2;
	UIImage* crossWinImage2;
	UIImage* fullWinImage2;

	UIImage* strokeImage3;
	UIImage* crossImage3;
	UIImage* fullImage3;
	UIImage* strokeWinImage3;
	UIImage* crossWinImage3;
	UIImage* fullWinImage3;

	GameModel* gameModel;

	// Which frame we're animating.
	int pressedAnim;
}

@property (nonatomic, retain) UIImage* backgroundImage;
@property (nonatomic, retain) UIImage* topImage;
@property (nonatomic, retain) UIImage* bottomImage;
@property (nonatomic, retain) UIImage* arrowTopLeftImage;
@property (nonatomic, retain) UIImage* arrowTopRightImage;
@property (nonatomic, retain) UIImage* arrowBottomLeftImage;
@property (nonatomic, retain) UIImage* arrowBottomRightImage;

@property (nonatomic, retain) UIImage* strokeImage1;
@property (nonatomic, retain) UIImage* crossImage1;
@property (nonatomic, retain) UIImage* fullImage1;
@property (nonatomic, retain) UIImage* strokeWinImage1;
@property (nonatomic, retain) UIImage* crossWinImage1;
@property (nonatomic, retain) UIImage* fullWinImage1;

@property (nonatomic, retain) UIImage* strokeImage2;
@property (nonatomic, retain) UIImage* crossImage2;
@property (nonatomic, retain) UIImage* fullImage2;
@property (nonatomic, retain) UIImage* strokeWinImage2;
@property (nonatomic, retain) UIImage* crossWinImage2;
@property (nonatomic, retain) UIImage* fullWinImage2;

@property (nonatomic, retain) UIImage* strokeImage3;
@property (nonatomic, retain) UIImage* crossImage3;
@property (nonatomic, retain) UIImage* fullImage3;
@property (nonatomic, retain) UIImage* strokeWinImage3;
@property (nonatomic, retain) UIImage* crossWinImage3;
@property (nonatomic, retain) UIImage* fullWinImage3;

@property (nonatomic, assign) GameModel* gameModel;

- (void)resetPressedAnim;
- (void)animatePressedSquare;

@end
