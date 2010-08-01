
#import "RootViewController.h"
#import "IntroViewController.h"
#import "GameModel.h"

extern int theme;
extern BOOL withSfx;

@interface IntroViewController (Private)
- (void)updateThemeButton;
- (void)updateSfxButton;
@end

@implementation IntroViewController

@synthesize rootViewController;
@synthesize onePlayerButton;
@synthesize twoPlayersButton;
@synthesize noPlayersButton;
@synthesize helpButton;
@synthesize themeButton;
@synthesize sfxButton;

- (void)viewDidLoad
{
	[self updateThemeButton];
	[self updateSfxButton];
}

- (IBAction)startOnePlayer
{
	[rootViewController startGame:self inMode:GAME_MODE_ONE_PLAYER];
}

- (IBAction)startTwoPlayers
{
	[rootViewController startGame:self inMode:GAME_MODE_TWO_PLAYERS];
}

- (IBAction)startNoPlayers
{
	[rootViewController startGame:self inMode:GAME_MODE_NO_PLAYERS];
}

- (IBAction)showHelp
{
	[rootViewController showHelp:self];
}

- (IBAction)launchUrl
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fnurglewitz.com"]];
}

- (IBAction)toggleTheme
{
	++theme;
	if (theme >= NUM_THEMES)
		theme = 0;

	[self updateThemeButton];
}

- (void)updateThemeButton
{
	NSString* title = nil;
	switch (theme)
	{
		case THEME_STROKES: title = @"Theme: Strokes"; break;
		case THEME_BUBBLES: title = @"Theme: Bubbles"; break;
		case THEME_EGGS:    title = @"Theme: Eggs"; break;
	}
			
	[themeButton setTitle:title forState:UIControlStateNormal];
	[themeButton setTitle:title forState:UIControlStateHighlighted];
}

- (IBAction)toggleSfx
{
	withSfx = !withSfx;
	[self updateSfxButton];
}

- (void)updateSfxButton
{
	NSString* title = withSfx ? @"Sound Effects: On" : @"Sound Effects: Off";
	[sfxButton setTitle:title forState:UIControlStateNormal];
	[sfxButton setTitle:title forState:UIControlStateHighlighted];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[onePlayerButton release];
	[twoPlayersButton release];
	[noPlayersButton release];
	[helpButton release];
	[themeButton release];
	[sfxButton release];
	[super dealloc];
}

@end
