
#import "FnurgletoeAppDelegate.h"
#import "RootViewController.h"

static NSString* ThemeKey   = @"ThemeKey";
static NSString* WithSfxKey = @"WithSfxKey";

// Not very nice to put these here as globals, but it will do.
int theme;
BOOL withSfx;

@implementation FnurgletoeAppDelegate

@synthesize window;
@synthesize rootViewController;

+ (void)initialize
{
	if ([self class] == [FnurgletoeAppDelegate class])
	{
		NSNumber* defaultTheme = [NSNumber numberWithInt:0];    // bubbles
		NSNumber* defaultWithSfx = [NSNumber numberWithInt:1];  // Should really be a bool!

		NSArray* keys = [NSArray arrayWithObjects:ThemeKey, WithSfxKey, nil];
		NSArray* objects = [NSArray arrayWithObjects:defaultTheme, defaultWithSfx, nil];

		NSDictionary* resourceDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
		[[NSUserDefaults standardUserDefaults] registerDefaults:resourceDict];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
	theme = [[NSUserDefaults standardUserDefaults] integerForKey:ThemeKey];
	withSfx = [[NSUserDefaults standardUserDefaults] boolForKey:WithSfxKey];

	RootViewController* viewController = [[RootViewController alloc] init];
	self.rootViewController = viewController;
	[viewController release];


	[window addSubview:[rootViewController view]];		
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	[[NSUserDefaults standardUserDefaults] setInteger:theme forKey:ThemeKey];
	[[NSUserDefaults standardUserDefaults] setBool:withSfx forKey:WithSfxKey];
}

- (void)dealloc
{
	[rootViewController release];
	[window release];
	[super dealloc];
}

@end
