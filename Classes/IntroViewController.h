
@class RootViewController;

/*
 * The Intro screen just contains a few buttons and some static "about" text.
 */
@interface IntroViewController : UIViewController
{
	RootViewController* rootViewController;
	UIButton* onePlayerButton;	
	UIButton* twoPlayersButton;
	UIButton* noPlayersButton;
	UIButton* helpButton;
	UIButton* themeButton;
	UIButton* sfxButton;
}

@property (nonatomic, assign) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet UIButton* onePlayerButton;	
@property (nonatomic, retain) IBOutlet UIButton* twoPlayersButton;
@property (nonatomic, retain) IBOutlet UIButton* noPlayersButton;
@property (nonatomic, retain) IBOutlet UIButton* helpButton;	
@property (nonatomic, retain) IBOutlet UIButton* themeButton;	
@property (nonatomic, retain) IBOutlet UIButton* sfxButton;	

- (IBAction)startOnePlayer;
- (IBAction)startTwoPlayers;
- (IBAction)startNoPlayers;
- (IBAction)showHelp;
- (IBAction)launchUrl;
- (IBAction)toggleTheme;
- (IBAction)toggleSfx;

@end
