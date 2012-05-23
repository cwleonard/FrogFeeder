//
//  EAGLView.m
//  FrogFeeder
//
//  Created by Casey Leonard on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#include <AudioToolbox/AudioToolbox.h>
#import <mach/mach.h>
#import <mach/mach_time.h>
#import "EAGLView.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) updateScene:(float)delta;
- (void) renderScene;
- (void) initGame;
- (void) initOpenGL;

@end


@implementation EAGLView

@synthesize context;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		// Get the bounds of the main screen
		screenBounds = [[UIScreen mainScreen] bounds];
		
		[self firstTimeInit];
		
		// Go and initialise the game entities and graphics etc
		[self initGame];
		
    }
    return self;
}

- (void)firstTimeInit {
	
	// setup sounds
	CFBundleRef mainBundle;
	mainBundle = CFBundleGetMainBundle ();
	
	// Get the URL to the sound file to play
	CFURLRef soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("button-16"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &frogTap);
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("frog_ribbit02"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &frogSwipe);
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("splash05"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &splash);
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("click16a"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &lillyPadTap);	
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("pop2b"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &lillyPadSwipe);		
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("chomp05"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &eat);		
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("button_click_start"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &buttonClickStart);		
	soundFileURLRef  =    CFBundleCopyResourceURL (mainBundle, CFSTR ("button_click_end"), CFSTR ("wav"), NULL);
	AudioServicesCreateSystemSoundID (soundFileURLRef, &buttonClickEnd);		
	
	// Enable Multi Touch of the view
    self.multipleTouchEnabled = YES;
	
	numberSheet = [[SpriteSheet alloc] initWithImageNamed:@"sb_numbers.png" spriteWidth:35 spriteHeight:35 spacing:0 imageScale:0.66];
	hsNumberSheet = [[SpriteSheet alloc] initWithImageNamed:@"high_score_numbers_2.png" spriteWidth:8 spriteHeight:9 spacing:0 imageScale:1.0];
	scoreLegend = [[Image alloc] initWithImage:[UIImage imageNamed:@"sb_score.png"] filter:GL_LINEAR];
	
	gameOverImage = [[Image alloc] initWithImage:[UIImage imageNamed:@"game_over.png"] filter:GL_LINEAR];
	
	splashScreen = [[Image alloc] initWithImage:[UIImage imageNamed:@"main_screen.png"] filter:GL_LINEAR];
	continueImage = [[Image alloc] initWithImage:[UIImage imageNamed:@"continue.png"] filter:GL_LINEAR]; 
	
	creditsScreen = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits_screen.png"] filter:GL_LINEAR];

	credits[0] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits1.png"] filter:GL_LINEAR];
	credits[1] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits2.png"] filter:GL_LINEAR];
	credits[2] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits3.png"] filter:GL_LINEAR];
	credits[3] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits4.png"] filter:GL_LINEAR];
	credits[4] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits5.png"] filter:GL_LINEAR];
	credits[5] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits6.png"] filter:GL_LINEAR];
	credits[6] = [[Image alloc] initWithImage:[UIImage imageNamed:@"credits7.png"] filter:GL_LINEAR];
	

	howToScreen = [[Image alloc] initWithImage:[UIImage imageNamed:@"how-to.png"] filter:GL_LINEAR];
	frogOnLillyPad = [[Image alloc] initWithImage:[UIImage imageNamed:@"frog_on_lillypad.png"] filter:GL_LINEAR];

	bonusX2 = [[Image alloc] initWithImage:[UIImage imageNamed:@"bonusX2.png"] filter:GL_LINEAR];
	bonusX3 = [[Image alloc] initWithImage:[UIImage imageNamed:@"bonusX3.png"] filter:GL_LINEAR];
	bonusX4 = [[Image alloc] initWithImage:[UIImage imageNamed:@"bonusX4.png"] filter:GL_LINEAR];
	
	water = [[Image alloc] initWithImage:[UIImage imageNamed:@"water3.png"] filter:GL_LINEAR];
	playButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"play.png"] filter:GL_LINEAR];
	pauseButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"pause.png"] filter:GL_LINEAR];
	[playButton setScale:0.55];
	[pauseButton setScale:0.55];
	
	ripples = [[SpriteSheet alloc] initWithImageNamed:@"ripples.png" spriteWidth:40 spriteHeight:40 spacing:0 imageScale:1.0];
	
	// ====================== TEXTURES THAT WE'LL USE FOR MULTIPLE GAME SPRITES ===========
	
	bfoTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"brown_frog_eyes_open_40x40.png"] filter:GL_LINEAR];
	bfcTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"brown_frog_eyes_closed_40x40.png"] filter:GL_LINEAR];
	bfjTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"brown_frog_jumping_26x47.png"] filter:GL_LINEAR];
	gfoTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"spotted_frog_eyes_open_40x40.png"] filter:GL_LINEAR];
	gfcTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"spotted_frog_eyes_closed_40x40.png"] filter:GL_LINEAR];
	gfjTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"spotted_frog_jumping_26x47.png"] filter:GL_LINEAR];
	ftTex  = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"tounge.png"] filter:GL_LINEAR];
	faTex  = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"alert.png"] filter:GL_LINEAR];
	lpTex  = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"lp_40x40_test.png"] filter:GL_LINEAR];
	bTex   = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"dragonfly.png"] filter:GL_LINEAR];
	
	// ====================================================================================
	
	
	// ===================== BUTTON RECTANGLES ======================
	
	paRect = CGRectMake(107, 292, 193, 30);
	menuRect = CGRectMake(168, 334, 99, 30);
	playRect = CGRectMake(110, 363, 107, 34);
	creditsRect = CGRectMake(178, 418, 114, 23);
	howRect = CGRectMake(27, 418, 114, 23);
	menu1Rect = CGRectMake(114, 438, 114, 23);
	menu2Rect = CGRectMake(176, 402, 114, 23);
	yesRect = CGRectMake(70, 270, 65, 25);
	noRect = CGRectMake(193, 270, 56, 25);
	pgRect = CGRectMake(0, 0, 40, 40);
	
	// ==============================================================

	frogRotation1 = 0.0;
	frogRotation2 = 270.0;
	
	bugsToRemove = [[NSMutableArray alloc] init];
	
	splashes = [[NSMutableArray alloc] init];
	
	playback = [[oalPlayback alloc] init];
	
	highscore = [self loadHighScore];
	
}

- (void)initGame {
	
	buttonPressed = -1;
	
	fadeout = NO;
	[playback setSourcePos:CGPointMake(0,-125)];
	if (![playback isPlaying]) {
		[playback startSound];
	}
	
	creditsX = 400;
	
	gameOver = NO;
	
	gameMode = GAME_MODE_MENU;
	
	addFrogs = 0;
	
	oneSecondCounter = 0;
	secondsCounter = 0;
	gameLengthCounter = 0;
	minutesCounter = 0;
	
	lastTime = CFAbsoluteTimeGetCurrent();
	
	glInitialised = NO;
	
	bugsEaten = 0;
	
	generalTimer = 0.0;
	
	[splashes removeAllObjects];
	
	gameGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	frogGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	bugsGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	
	
	// ----------------------- test stuff, remove later --------------
	
	
//	PlatformSprite* l = [[PlatformSprite alloc] initWithPosition: 0: 1: lpTex: YES];
//	[gameGrid addObjectAtPosition:0 :1 :l];
//
//	l = [[PlatformSprite alloc] initWithPosition: 0: 2: lpTex: YES];
//	[gameGrid addObjectAtPosition:0 :2 :l];
//
//	l = [[PlatformSprite alloc] initWithPosition: 0: 3: lpTex: YES];
//	[gameGrid addObjectAtPosition:0 :3 :l];
//
//	l = [[PlatformSprite alloc] initWithPosition: 1: 1: lpTex: YES];
//	[gameGrid addObjectAtPosition:1 :1 :l];
//	
//	l = [[PlatformSprite alloc] initWithPosition: 1: 2: lpTex: YES];
//	[gameGrid addObjectAtPosition:1 :2 :l];
//	
//	l = [[PlatformSprite alloc] initWithPosition: 1: 3: lpTex: YES];
//	[gameGrid addObjectAtPosition:1 :3 :l];
//	
//	BugSprite* b = [[BugSprite alloc] initWithPosition:1 :1: bTex];
//	[bugsGrid addObjectAtPosition:1 :1 :b];
//
//	b = [[BugSprite alloc] initWithPosition:1 :2: bTex];
//	[bugsGrid addObjectAtPosition:1 :2 :b];
//
//	b = [[BugSprite alloc] initWithPosition:1 :3: bTex];
//	[bugsGrid addObjectAtPosition:1 :3 :b];
//
//	FrogSprite* f = [[FrogSprite alloc] initWithPosition:0 :1: bfoTex: bfcTex: bfjTex: gfoTex: gfcTex: gfjTex: ftTex: faTex];
//	[frogGrid addObjectAtPosition:0 :1 :f];
//
//	f = [[FrogSprite alloc] initWithPosition:0 :2: bfoTex: bfcTex: bfjTex: gfoTex: gfcTex: gfjTex: ftTex: faTex];
//	[frogGrid addObjectAtPosition:0 :2 :f];
//	
//	f = [[FrogSprite alloc] initWithPosition:0 :3: bfoTex: bfcTex: bfjTex: gfoTex: gfcTex: gfjTex: ftTex: faTex];
//	[frogGrid addObjectAtPosition:0 :3 :f];

	
	// ---------------------------------------------------------------
	
	
	// make lilly pads
	for (int i = 0; i < DEFAULT_NUM_PADS; i++) {
		[self createLillyPad];
	}
	
	// make frogs
	[self createFrog];
	
	// make some bugs
	for (int i = 0; i < DEFAULT_NUM_BUGS; i++) {
		[self createBug];
	}
	
	// set up the countdown
	numSeconds = 5; //lroundf((float)[[frogGrid getObjects] count] * SECONDS_PER_FROG);
	
	hungryFrogs = 1;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/savedgame.dat"];
	NSFileManager* fm = [NSFileManager defaultManager];
	savedGameExists = [fm fileExistsAtPath:fname];
	
}

- (void)createLillyPad {
	
	int x = arc4random() % GRID_WIDTH;
	int y = arc4random() % GRID_HEIGHT;
	
	while ([gameGrid objectAtPosition:x :y]) {
		x = arc4random() % GRID_WIDTH;
		y = arc4random() % GRID_HEIGHT;
	}
	
	BOOL g = (gameMode == GAME_MODE_CHECK);
	
	PlatformSprite* l = [[PlatformSprite alloc] initWithPosition: x: y: lpTex: g];
	[gameGrid addObjectAtPosition:x :y :l];
	
}

- (void)createFrog {
	
	int x = arc4random() % GRID_WIDTH;
	int y = arc4random() % GRID_HEIGHT;
	
	while (![gameGrid objectAtPosition:x :y] || [frogGrid objectAtPosition:x :y] || [bugsGrid objectAtPosition:x :y]) {
		x = arc4random() % GRID_WIDTH;
		y = arc4random() % GRID_HEIGHT;
	}
	
	FrogSprite* f = [[FrogSprite alloc] initWithPosition:x :y: bfoTex: bfcTex: bfjTex: gfoTex: gfcTex: gfjTex: ftTex: faTex];
	[frogGrid addObjectAtPosition:x :y :f];
	[self setFrogAlert: f];
	
}

- (void)createBug {
	
	int x = arc4random() % GRID_WIDTH;
	int y = arc4random() % GRID_HEIGHT;
	
	while ([frogGrid objectAtPosition:x :y] || [bugsGrid objectAtPosition:x :y]) {
		x = arc4random() % GRID_WIDTH;
		y = arc4random() % GRID_HEIGHT;
	}
	
	BugSprite* b = [[BugSprite alloc] initWithPosition:x :y: bTex];
	[bugsGrid addObjectAtPosition:x :y :b];
	
}

- (void)mainGameLoop {
	
	// Create variables to hold the current time and calculated delta
	CFTimeInterval		time;
	float				delta;
	
	// This is the heart of the game loop and will keep on looping until it is told otherwise
	//while(!gameOver) {
	
	// Create an autorelease pool which can be used within this tight loop.  This is a memory
	// leak when using NSString stringWithFormat in the renderScene method.  Adding a specific
	// autorelease pool stops the memory leak
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// I found this trick on iDevGames.com.  The command below pumps events which take place
	// such as screen touches etc so they are handled and then runs our code.  This means
	// that we are always in sync with VBL rather than an NSTimer and VBL being out of sync
	while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002, TRUE) == kCFRunLoopRunHandledSource);
	
	// Get the current time and calculate the delta between the lasttime and now
	// We multiply the delta by 1000 to give us milliseconds
	time = CFAbsoluteTimeGetCurrent();
	delta = (time - lastTime) * 1000;
	
	// Go and update the game logic and then render the scene
	
	if (gameMode != GAME_MODE_PAUSE) {
		[self updateScene:delta];
	}
	
	[self renderScene];
	
	// Set the lasttime to the current time ready for the next pass
	lastTime = time;
	
	// Release the autorelease pool so that it is drained
	[pool release];
	//}
	
	//NSLog(@"GAME OVER!");
	
	//[gameLoopTimer invalidate];
	
}


- (void)updateScene:(float)delta {
	
	if (gameOver) {
		if ([gameOverImage scale] < 1.0) {
			[gameOverImage setScale: [gameOverImage scale] + (delta * 0.0036)];
			if ([gameOverImage scale] > 1.0) {
				[gameOverImage setScale: 1.0];
			}
		}
		return;
	}
	
	if (gameMode != GAME_MODE_MENU && fadeout) {
	
		if ([playback isPlaying]) {
			CGPoint p = [playback sourcePos];
			p.y -= (delta * 0.04);
			[playback setSourcePos:p];
			if (p.y < -1400) {
				[playback stopSound];
			}
		}
		
	}
	
	if (gameMode == GAME_MODE_MENU) {
		if (promptToContinue && [continueImage scale] < 1.0) {
			[continueImage setScale: [continueImage scale] + (delta * 0.0036)];
			if ([continueImage scale] > 1.0) {
				[continueImage setScale: 1.0];
			}
		} else if (showCredits) {
			
			creditsX = creditsX - (delta * 0.08);
			if (creditsX < -2800) {
				creditsX = 500;
			}
			
		} else if (showInstructions) {
			
			frogRotation1 -= (delta * 0.008);
			frogRotation2 += (delta * 0.012);
			
		}
		return;
	}
	
	
	if (gameMode != GAME_MODE_ADD) {
		
		oneSecondCounter += delta;
		
		if (showBonus) {
			[bonusShowing setAlpha: 1.0 - (bonusDisplayCounter / 1500.0)];
			bonusDisplayCounter += delta;
			if (bonusDisplayCounter > 1500) {
				showBonus = NO;
			}
		}
		
		if (oneSecondCounter >= 1000.0) {
			
			oneSecondCounter = (int)oneSecondCounter % 1000;
			secondsCounter++;
			gameLengthCounter++;
			
			NSArray* frogs = [frogGrid getObjects];
			for (int i = 0; i < [frogs count]; i++) {
				[ [frogs objectAtIndex:i] considerBlinking ];
			}
			[frogs release];
			
		}
		
		minutesCounter = gameLengthCounter / 120;
		
		NSArray* fcheck = [frogGrid getObjects];
		int numFrogs = [fcheck count];
		if (numFrogs == 0) {
			gameOver = YES;
			if (bugsEaten > highscore) {
				highscore = bugsEaten;
				[self saveHighScore: highscore];
			}
			[gameOverImage setScale: 0.1];
			return;
		}
		[fcheck release];
		
	} else {
		
		generalTimer += delta;
		
	}
	
	// ================ GENERAL UPDATES, FOR ANIMATION OF SPRITES ==============
	
	NSArray* bugs = [bugsGrid getObjects];
	for (int i = 0; i < [bugs count]; i++) {
		[ [bugs objectAtIndex:i] update: delta ];
		
	}
	[bugs release];
	
	NSArray* frogs = [frogGrid getObjects];
	for (int i = 0; i < [frogs count]; i++) {
		[ [frogs objectAtIndex:i] update: delta ];
	}
	[frogs release];
	
	NSArray* pads = [gameGrid getObjects];
	for (int i = 0; i < [pads count]; i++) {
		PlatformSprite* p = [pads objectAtIndex:i];
		// a frog weighs down a lilly pad, so they don't move whilst a frog sits upon them
		[[pads objectAtIndex:i] update: delta :[frogGrid objectAtPosition:[p getGridPositionX] :[p getGridPositionY]]];
	}
	[pads release];
	
	for (int i = 0; i < [splashes count]; i++) {
		[[splashes objectAtIndex:i] update: delta];
	}
	
	// =========================================================================
	
	if (secondsCounter == numSeconds && gameMode == GAME_MODE_NORMAL) {
		
		fadeout = YES;
		
		gameMode = GAME_MODE_EAT;
		
		// save off how many bugs we had before the frogs eat
		int oldNumBugs = bugsEaten;
		
		// frogs start eating
		NSArray* frogs = [frogGrid getObjects];
		for (int i = 0; i < [frogs count]; i++) {
			
			FrogSprite* tempFrog = [frogs objectAtIndex:i];
			
			// cancel any touches on the frogs
			[tempFrog setTouched:NO];
			
			CGPoint nextPos = [tempFrog getNextPosition];
			int q = nextPos.x;
			int r = nextPos.y;
			
			if ([bugsGrid objectAtPosition:q :r]) {
				
				// eat a bug
				BugSprite* bug = [bugsGrid spriteAtPosition:q :r];
				[tempFrog startEating];
				[bug eatenAt:[tempFrog getGridPosition]];
				[bugsToRemove addObject:bug];
				bugsEaten++;
				if ([tempFrog hungry]) {
					[tempFrog setHungry:NO];
					hungryFrogs--;
				}
				
			}
			
		}
		[frogs release];
		
		// check if we need to award a bonus
		int eatenThisRound = bugsEaten - oldNumBugs;
		if (eatenThisRound > 1) {
			bugsEaten = (bugsEaten - eatenThisRound) + (eatenThisRound * eatenThisRound);
			if (eatenThisRound == 2) {
				showBonus = YES;
				bonusDisplayCounter = 0.0;
				bonusShowing = bonusX2;
				[bonusShowing setScale:0.8];
			} else if (eatenThisRound == 3) {
				showBonus = YES;
				bonusDisplayCounter = 0.0;
				bonusShowing = bonusX3;
				[bonusShowing setScale:0.9];
			} else if (eatenThisRound > 3) {
				showBonus = YES;
				bonusDisplayCounter = 0.0;
				bonusShowing = bonusX4;
				[bonusShowing setScale:1.0];
			}
		}
		
		if (oldNumBugs < bugsEaten) {
			if (eatenThisRound == 1 && (bugsEaten % POINTS_PER_NEW_FROG == 0)) {
				addFrogs = 1;
			} else {
				addFrogs = eatenThisRound / POINTS_PER_NEW_FROG;
			}
		} else {
			addFrogs = 0;
		}
		
		
	}
	
	if (oneSecondCounter >= 500.0 && gameMode == GAME_MODE_EAT) {
		
		gameMode = GAME_MODE_JUMP;
		
		if ([bugsToRemove count] > 0) {
			for (int i = 0; i < [bugsToRemove count]; i++) {
				BugSprite* b = [bugsToRemove objectAtIndex:i];
				[bugsGrid removeObjectAtPosition:[b getGridPosition].x :[b getGridPosition].y];
			}
			AudioServicesPlaySystemSound (eat);	
		}
		[bugsToRemove removeAllObjects];
		
		// jump all the frogs
		NSArray* frogs = [frogGrid getObjects];
		for (int i = 0; i < [frogs count]; i++) {
			
			// cancel any touches on the frogs
			FrogSprite* frog = [frogs objectAtIndex:i];
			
			// look for frog collisions
			CGPoint np = [frog getNextPosition];
			for (int j = 0; j < [frogs count]; j++) {
				if (j != i) { // we can skip the frog we're already working on
					FrogSprite* frog2 = [frogs objectAtIndex:j];
					if ([gameGrid objectAtPosition:np.x: np.y] && [frog2 getNextPosition].x == np.x && [frog2 getNextPosition].y == np.y) {
						// too many frogs on one lilly pad! sink it!
						[[gameGrid spriteAtPosition:np.x :np.y] setMultipleLanding:YES];
					}
				}
			}
			
			[frog setTouched:NO];
			[frog endEating ];
		}
		
		// now that we're done checking for collisions, we can jump the frogs
		for (int i = 0; i < [frogs count]; i++) {
			[[frogs objectAtIndex:i] startJump];
		}
		
		[frogs release];
		
		// cancel any touches on lilly pads
		NSArray* objs = [gameGrid getObjects];
		for (int i = 0; i < [objs count]; i++) {
			[[objs objectAtIndex:i] setTouched:NO];
		}
		[objs release];
		
	}
	
	if (secondsCounter == numSeconds + 1 && /* oneSecondCounter >= 200 && */ gameMode == GAME_MODE_JUMP) {
		
		gameMode = GAME_MODE_CHECK;
		
		NSArray* frogs = [frogGrid getObjects];
		for (int i = 0; i < [frogs count]; i++) {
			[ [frogs objectAtIndex:i] endJump ];
		}
		[frogs release];
		
		oneSecondCounter = (int)oneSecondCounter % 200;
		
	}
	
	if (gameMode == GAME_MODE_CHECK) {
		
		// check for splashes that are done splashing
		
		NSMutableArray* str = [[NSMutableArray alloc] init];
		for (int i = 0; i < [splashes count]; i++) {
			if (![[splashes objectAtIndex:i] animating]) {
				[str addObject:[splashes objectAtIndex:i]];
			}
		}
		for (int i = 0; i < [str count]; i++) {
			[splashes removeObject:[str objectAtIndex:i]];
		}
		[str removeAllObjects];
		[str release];
		
		
		// check for sinking lilly pads
		
		NSArray* objs = [gameGrid getObjects];
		for (int i = 0; i < [objs count]; i++) {
			
			PlatformSprite* temp = [objs objectAtIndex:i];
			int q = [temp getGridPositionX];
			int r = [temp getGridPositionY];
			
			//NSLog(@"lilly pad at %d, %d", q, r);
			
			if (![temp stillFloating]) {
				[gameGrid removeObjectAtPosition: q: r];
			}
			
		}
		[objs release];
		
		// check for sinking frogs
		
		BOOL makeSinkingSound = NO;
		NSArray* frogs = [frogGrid getObjects];
		for (int i = 0; i < [frogs count]; i++) {
			
			FrogSprite* f = [frogs objectAtIndex:i];
			
			CGPoint gp = [f getGridPosition];
			int q = (int)gp.x;
			int r = (int)gp.y;
			
			CGPoint lp = [f getLastGridPosition];
			int lq = (int)lp.x;
			int lr = (int)lp.y;
			
			//NSLog(@"last position was (%d, %d) and new position is (%d, %d)", lq, lr, q, r);
			
			
			// if frog changed position, update the grid
			if ( (q != lq) || (r != lr) ) {
				[frogGrid positionObject:lq :lr :q :r :f];
			}
			
			if (![gameGrid objectAtPosition:q :r]) {
				
				//NSLog(@"frog at position %d, %d is sinking!", q, r);
				makeSinkingSound = YES;
				[frogGrid removeObjectAtPosition: q: r];
				
				SplashSprite* sp = [[SplashSprite alloc] initWithPosition:q :r :ripples];
				[splashes addObject:sp];
				
				
			} else {
				
				// only do this stuff if a frog actually moved (dont worry about the ones at the screen edges that just rotate)
				if ( (q != lq) || (r != lr) ) {
					
					//NSLog(@"frog changed position, checking for landings");
					[[gameGrid spriteAtPosition:q :r] landedOn];
					
				}
				
				[self setFrogAlert: f];
				
			}
			
		}
		
		[frogGrid cleanup];
		[frogs release];
		
		if (makeSinkingSound) {
			AudioServicesPlaySystemSound (splash);	
		}
		
		
		
		
		// ----------------------------------------------------------
		
		//		BOOL foundBad = NO;
		//		for (int i = 0; i < GRID_WIDTH; i++) {
		//			
		//			for (int j = 0; j < GRID_HEIGHT; j++) {
		//				
		//				FrogSprite* tempFrog = [frogGrid spriteAtPosition:i :j];
		//				
		//				if (tempFrog != [NSNull null]) {
		//				
		//					CGPoint loc = [tempFrog getGridPosition];
		//					int fx = (int)loc.x;
		//					int fy = (int)loc.y;
		//				
		//					if ( (fx != i) || (fy != j) ) {
		//					
		//						NSLog(@"frog at grid position (%d, %d) does not match its internal position of (%d, %d)!", i, j, fx, fy);
		//						foundBad = YES;
		//					
		//					}
		//					
		//				}
		
		//				
		//			}
		//			
		//		}
		//		
		//		if (foundBad) {
		//			gameOver = YES;
		//		}
		
		
		// ----------------------------------------------------------
		
		// ============================ ADDITIONAL OBJECTS LOGIC ==================
		
		BOOL addedSomething = NO;
		
		int currentNumberOfFrogs = [[frogGrid getObjects] count];
		int currentNumberOfPads = [[gameGrid getObjects] count];
		int currentNumberOfBugs = [[bugsGrid getObjects] count];
		
		// maybe add more lilly pads
		
		if (currentNumberOfPads < DEFAULT_NUM_PADS) {
			[self createLillyPad];
			addedSomething = YES;
		}
		
		// maybe add another frog
		for (int i = 0; i < addFrogs; i++) {
			if (currentNumberOfFrogs < DEFAULT_NUM_FROGS) {
				[self createFrog];
				currentNumberOfFrogs++;
				hungryFrogs++;
				addedSomething = YES;
			}
		}
		
		// maybe add another bug
		if (currentNumberOfBugs < currentNumberOfFrogs + 1) {
			[self createBug];
			addedSomething = YES;
		}
		
		// determine how long before the frogs jump again
		numSeconds = lroundf((float)[[frogGrid getObjects] count] * SECONDS_PER_FROG) - minutesCounter;
//		if (numSeconds < currentNumberOfFrogs + 1) {
//			numSeconds = currentNumberOfFrogs + 1; 
//		}
		if (numSeconds > 5) {
			numSeconds = 5;
		}
		if (numSeconds < 2) {
			numSeconds = 2; 
		}
		
		// reset the counter
		secondsCounter = 0;
		
		if (addedSomething) {
			gameMode = GAME_MODE_ADD;
			NSArray* frogs = [frogGrid getObjects];
			for (int i = 0; i < [frogs count]; i++) {
				[self setFrogAlert: [frogs objectAtIndex:i]];
			}
			[frogs release];
		} else {
			gameMode = GAME_MODE_NORMAL;
		}
		
		generalTimer = 0.0;
		
	}
	
	if (generalTimer >= 500.0 && gameMode == GAME_MODE_ADD) {
		
		// just give the stuff some time to animate arrivals
		
		gameMode = GAME_MODE_NORMAL;
		generalTimer = 0.0;
		
	}
	
	
	
	
}


- (void)renderScene {
    
	// If OpenGL has not yet been initialised then go and initialise it
	if(!glInitialised) {
		[self initOpenGL];
	}
	
	// Set the current EAGLContext and bind to the framebuffer.  This will direct all OGL commands to the
	// framebuffer and the associated renderbuffer attachment which is where our scene will be rendered
	[EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
	// Define the viewport.  Changing the settings for the viewport can allow you to scale the viewport
	// as well as the dimensions etc and so I'm setting it for each frame in case we want to change it
	glViewport(0, 0, screenBounds.size.width , screenBounds.size.height);
	
	// Clear the screen.  If we are going to draw a background image then this clear is not necessary
	// as drawing the background image will destroy the previous image
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Setup how the images are to be blended when rendered.  This could be changed at different points during your
	// render process if you wanted to apply different effects
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	//Render the game Scene	
	
	if (gameMode == GAME_MODE_MENU) {
		
		if (showCredits) {
			
			[creditsScreen renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			
			int y = 350;
			int cSpace = 400;
			
			for (int i = 0; i < 7; i++) {
				[credits[i] renderAtPoint:CGPointMake(creditsX + (cSpace * i), y) centerOfImage:YES];
			}
			
		} else if (showInstructions) {
			
			[howToScreen renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			[frogOnLillyPad setRotation: frogRotation1];
			[frogOnLillyPad renderAtPoint:CGPointMake(260, 345) centerOfImage:YES];
			[frogOnLillyPad setRotation: frogRotation2];
			[frogOnLillyPad renderAtPoint:CGPointMake(93, 58) centerOfImage:YES];
			
		} else {
			[splashScreen renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			[self drawScoreBoard: YES];
			if (promptToContinue) {
				[continueImage renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			}
		}
		
		
	} else {
		
		[water renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
		
		for (int i = 0; i < [splashes count]; i++) {
			[[splashes objectAtIndex:i] render];
		}
		
		NSArray* objs = [gameGrid getObjects];
		for (int i = 0; i < [objs count]; i++) {
			[ [objs objectAtIndex:i] render ];
		}
		
		NSArray* bugs = [bugsGrid getObjects];
		for (int i = 0; i < [bugs count]; i++) {
			[ [bugs objectAtIndex:i] render ];
		}
		
		NSArray* frogs = [frogGrid getObjects];
		for	(int i = 0; i < [frogs count]; i++) {
			[ [frogs objectAtIndex:i] render ];
		}
		
		[objs release];
		[bugs release];
		[frogs release];
		
		
		[self drawScoreBoard];
		
		if (showBonus) {
			
			[bonusShowing renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			
		}
		
		if (gameOver) {
			
			// make the whole screen slightly darker
			
			glPushMatrix();
			glColor4f(0.0, 0.0, 0.0, 0.5);
			glEnableClientState(GL_VERTEX_ARRAY);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			
			float qv[] = { 0.0  , 480.0,
				320.0, 480.0,
				0.0  , 0.0,
			320.0, 0.0 };
			
			// Set up the VertexPointer to point to the vertices we have defined
			glVertexPointer(2, GL_FLOAT, 0, qv);
			
			// Enable blending as we want the transparent parts of the image to be transparent
			glEnable(GL_BLEND);
			
			// Draw the vertices to the screen
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glDisable(GL_BLEND);
			
			// Disable as necessary
			glDisableClientState(GL_VERTEX_ARRAY);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			
			// Restore the saved matrix from the stack
			glPopMatrix();
			
			[gameOverImage renderAtPoint:CGPointMake(160, 240) centerOfImage:YES];
			
		}
		
	}
	
	// Bind to the renderbuffer and then present this image to the current context
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

- (void)setFrogAlert: (FrogSprite*) f {
	
	CGPoint gp = [f getGridPosition];
	int q = (int)gp.x;
	int r = (int)gp.y;
	
	if ([f orientation] == up && r < (GRID_HEIGHT - 1) && ![gameGrid objectAtPosition:q :(r+1)]) {
		[f setAlert:YES];
	} else if ([f orientation] == down && (r > 0) && ![gameGrid objectAtPosition:q :(r-1)]) {
		[f setAlert:YES];
	} else if ([f orientation] == right && q < (GRID_WIDTH - 1) && ![gameGrid objectAtPosition:(q+1) :r]) {
		[f setAlert:YES];
	} else if ([f orientation] == left && q > 0 && ![gameGrid objectAtPosition:(q-1) :r]) {
		[f setAlert:YES];
	} else {
		[f setAlert:NO];
	}
	
}

- (void)drawScoreBoard {
	
	[self drawScoreBoard: NO];
	
}

- (void)drawScoreBoard: (BOOL)forMenu {
	
	if (forMenu) {
		// draw the high score
		int hundredsPlace = highscore / 100;
		int tensPlace = (highscore - (hundredsPlace * 100)) / 10;
		int onesPlace = highscore - (hundredsPlace * 100) - (tensPlace * 10);
		[hsNumberSheet renderSpriteAtX:hundredsPlace y:0 point:CGPointMake(92, 462) centerOfImage:YES];
		[hsNumberSheet renderSpriteAtX:tensPlace y:0 point:CGPointMake(100, 462) centerOfImage:YES];
		[hsNumberSheet renderSpriteAtX:onesPlace y:0 point:CGPointMake(108, 462) centerOfImage:YES];
		return;	
	}
	
	// draw a black rectangle at the top of the screen
	
	glPushMatrix();
	glColor4f(0.0, 0.0, 0.0, 1.0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	float qv[] = { 0.0  , 480.0,
		320.0, 480.0,
		0.0  , 442.0,
	320.0, 442.0 };
	
	// Set up the VertexPointer to point to the vertices we have defined
	glVertexPointer(2, GL_FLOAT, 0, qv);
	
	// Draw the vertices to the screen
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// Disable as necessary
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Restore the saved matrix from the stack
	glPopMatrix();
	
	[scoreLegend renderAtPoint:CGPointMake(185, 462) centerOfImage:YES];
	
	int hundredsPlace = 0;
	int tensPlace = 0;
	int onesPlace = 0;
	
	// draw the countdown timer
	int secondsLeft = numSeconds - secondsCounter;
	if (gameMode == GAME_MODE_NORMAL) {
		tensPlace = secondsLeft / 10;
		onesPlace = secondsLeft - (tensPlace * 10);
	} else {
		tensPlace = 0;
		onesPlace = 0;
	}
	[numberSheet renderSpriteAtX:tensPlace y:0 point:CGPointMake(72, 462) centerOfImage:YES];
	[numberSheet renderSpriteAtX:onesPlace y:0 point:CGPointMake(96, 462) centerOfImage:YES];

	
	// draw the play or pause button
	if (gameMode != GAME_MODE_PAUSE) {
		[pauseButton renderAtPoint:CGPointMake(20, 460) centerOfImage:YES];
	} else {
		[playButton renderAtPoint:CGPointMake(20, 460) centerOfImage:YES];
	}
	
	// draw the eaten bugs counter
	hundredsPlace = bugsEaten / 100;
	tensPlace = (bugsEaten- (hundredsPlace * 100)) / 10;
	onesPlace = bugsEaten - (hundredsPlace * 100) - (tensPlace * 10);
	[numberSheet renderSpriteAtX:hundredsPlace y:0 point:CGPointMake(258, 462) centerOfImage:YES];
	[numberSheet renderSpriteAtX:tensPlace y:0 point:CGPointMake(282, 462) centerOfImage:YES];
	[numberSheet renderSpriteAtX:onesPlace y:0 point:CGPointMake(306, 462) centerOfImage:YES];
	
	// draw the hungry frogs counter
	//	tensPlace = hungryFrogs / 10;
	//	onesPlace = hungryFrogs - (tensPlace * 10);
	//	[[numberSheet getSpriteAtX:tensPlace y:0] renderAtPoint:CGPointMake(300, 472) centerOfImage:YES];
	//	[[numberSheet getSpriteAtX:onesPlace y:0] renderAtPoint:CGPointMake(310, 472) centerOfImage:YES];
	
	
}

- (void)initOpenGL {
	
	// Switch to GL_PROJECTION matrix mode and reset the current matrix with the identity matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	// Setup Ortho for the current matrix mode.  This describes a transformation that is applied to
	// the projection.  For our needs we are defining the fact that 1 pixel on the screen is equal to
	// one OGL unit by defining the horizontal and vertical clipping planes to be from 0 to the views
	// dimensions.  The far clipping plane is set to -1 and the near to 1
	glOrthof(0, screenBounds.size.width, 0, screenBounds.size.height, -1, 1);
	
	// Switch to GL_MODELVIEW so we can now draw our objects
	glMatrixMode(GL_MODELVIEW);
	
	// Setup how textures should be rendered i.e. how a texture with alpha should be rendered ontop of
	// another texture.  We are setting this to GL_BLEND_SRC by default and not changing it during the
	// game
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	
	// We are going to be using GL_VERTEX_ARRAY to do all drawing within our game so it can be enabled once
	// If this was not the case then this would be set for each frame as necessary
	glEnableClientState(GL_VERTEX_ARRAY);
	
	// We are not using the depth buffer in our 2D game so depth testing can be disabled.  If depth
	// testing was required then a depth buffer would need to be created as well as enabling the depth
	// test
	glDisable(GL_DEPTH_TEST);
	
	// Set the colour to use when clearing the screen with glClear
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// Mark OGL as initialised
	glInitialised = YES;
	
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self renderScene];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)startAnimation {
	gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(mainGameLoop) userInfo:nil repeats:YES];
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)deleteSavedGame {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/savedgame.dat"];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:fname]) {
		[fm removeItemAtPath:fname error:NULL];
	}
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
	
	CGPoint p = [touch locationInView:self];
	//NSLog(@"touched at %f, %f", p.x, p.y);
	
	BOOL checkPads = YES;
	
	if (gameOver) {
		
		if (CGRectContainsPoint(paRect, p)) {
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_START_GAME;
		} else if (CGRectContainsPoint(menuRect, p)) {
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_MENU;
		}
		
	} else if (gameMode == GAME_MODE_MENU) {
		
		if (!promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(creditsRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_ABOUT;
			
		} else if (!promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(howRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_HOW_TO;
			
		} else if (showCredits && CGRectContainsPoint(menu1Rect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_MENU;
			
		} else if (showInstructions && CGRectContainsPoint(menu2Rect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_MENU;
			
		} else if (!promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(playRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_START_GAME;
			
		} else if (promptToContinue && CGRectContainsPoint(yesRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_YES;
			
		} else if (promptToContinue && CGRectContainsPoint(noRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_NO;
			
		}
		
	} else if (!gameOver) {
		
		if (CGRectContainsPoint(pgRect, p)) {
			AudioServicesPlaySystemSound (buttonClickStart);
			buttonPressed = BUTTON_PAUSE;
		}
		
		if (gameMode == GAME_MODE_NORMAL || gameMode == GAME_MODE_EAT) {
			
			NSArray* frogs = [frogGrid getObjects];
			for (int i = 0; i < [frogs count]; i++) {
				
				FrogSprite* temp = [frogs objectAtIndex:i];
				if ([temp containsPoint:p] && ![temp jumping]) {
					if (gameMode != GAME_MODE_EAT) {
						// dont allow re-pointing frogs while in eat mode, but if a frog is touched
						// we also don't want to touch the lilly pad under it
						[temp touchBeganAt:p];
						AudioServicesPlaySystemSound (frogTap);
					}
					checkPads = NO;
				}
				
			}
			[frogs release];
			
		}
		
		if (checkPads && gameMode != GAME_MODE_MENU && gameMode != GAME_MODE_ADD && gameMode != GAME_MODE_PAUSE) {
			NSArray* objs = [gameGrid getObjects];
			for (int i = 0; i < [objs count] && checkPads; i++) {
				
				if ([[objs objectAtIndex:i] containsPoint:p]) {
					[[objs objectAtIndex:i]touchBeganAt:p];
					AudioServicesPlaySystemSound (lillyPadTap);
				}
				
			}
			[objs release];
			
		}
		
	}
	
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint p = [touch locationInView:self];
	
	if (gameOver) {
		
		if (buttonPressed == BUTTON_START_GAME && CGRectContainsPoint(paRect, p)) {
			AudioServicesPlaySystemSound (buttonClickEnd);
			[self initGame];
			gameMode = GAME_MODE_NORMAL;
		} else if (buttonPressed == BUTTON_MENU && CGRectContainsPoint(menuRect, p)) {
			AudioServicesPlaySystemSound (buttonClickEnd);
			[self initGame];
		}
		
	} else if (gameMode == GAME_MODE_MENU) {
		
		if (buttonPressed == BUTTON_ABOUT && !promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(creditsRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickEnd);
			showCredits = YES;

		} else if (buttonPressed == BUTTON_HOW_TO && !promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(howRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickEnd);
			showInstructions = YES;
			
		} else if (buttonPressed == BUTTON_MENU && showCredits && CGRectContainsPoint(menu1Rect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickEnd);
			showCredits = NO;
			
		} else if (buttonPressed == BUTTON_MENU && showInstructions && CGRectContainsPoint(menu2Rect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickEnd);
			showInstructions = NO;
			
		} else if (buttonPressed == BUTTON_START_GAME && !promptToContinue && !showCredits && !showInstructions && CGRectContainsPoint(playRect, p)) {
			
			AudioServicesPlaySystemSound (buttonClickEnd);
			if (savedGameExists) {
				promptToContinue = YES;
				[continueImage setScale: 0.1];
			} else {
				gameMode = GAME_MODE_NORMAL;
			}
			
		} else if (buttonPressed == BUTTON_YES && promptToContinue && CGRectContainsPoint(yesRect, p)) {
			
			// yes, continue saved game
			AudioServicesPlaySystemSound (buttonClickEnd);
			promptToContinue = NO;
			[self loadGame];
			[self deleteSavedGame];
			
		} else if (buttonPressed == BUTTON_NO && promptToContinue && CGRectContainsPoint(noRect, p)) {
			
			// no, start a new game
			[self deleteSavedGame];
			AudioServicesPlaySystemSound (buttonClickEnd);
			promptToContinue = NO;
			gameMode = GAME_MODE_NORMAL;
			
		}
		
	} else {
		
		if (buttonPressed == BUTTON_PAUSE && CGRectContainsPoint(pgRect, p)) {
			AudioServicesPlaySystemSound (buttonClickEnd);
			if (gameMode == GAME_MODE_PAUSE) {
				gameMode = savedGameMode;
			} else {
				savedGameMode = gameMode;
				gameMode = GAME_MODE_PAUSE;
			}
			buttonPressed = -1;
			return;
		}
		
		NSArray* objs = [gameGrid getObjects];
		for (int i = 0; i < [objs count]; i++) {
			
			PlatformSprite* temp = [objs objectAtIndex:i];
			if ([temp touched]) {
				if ([temp touchEndedAt: p: gameGrid]) {
					[temp landedOn];
					AudioServicesPlaySystemSound (lillyPadSwipe);
					if (![temp stillFloating]) {
						int q = [temp getGridPositionX];
						int r = [temp getGridPositionY];
						[gameGrid removeObjectAtPosition: q: r];
					}
				}
			}
			
		}
		[objs release];
		
		NSArray* frogs = [frogGrid getObjects];
		for (int i = 0; i < [frogs count]; i++) {
			
			FrogSprite* frog = [frogs objectAtIndex:i];
			
			if ([frog touched]) {
				if ([frog touchEndedAt:p]) {
					AudioServicesPlaySystemSound (frogSwipe);
				}
			}
			
			[self setFrogAlert: frog];
			
		}
		[frogs release];
		
	}
	
	buttonPressed = -1;
	
}

- (void)pause {

	if (gameMode != GAME_MODE_MENU && gameMode != GAME_MODE_PAUSE) {
		savedGameMode = gameMode;
		gameMode = GAME_MODE_PAUSE;
	}
	
}

- (void)resume {
	gameMode = savedGameMode;
}

- (void)saveGame {
	
	/*	
	 ========== GENERAL GAME STUFF =========
	 
	 float generalTimer;
	 float oneSecondCounter;
	 float bonusDisplayCounter;
	 
	 int gameMode;
	 int savedGameMode;
	 int secondsCounter;
	 int gameLengthCounter;
	 int minutesCounter;
	 int numSeconds;
	 int hungryFrogs;
	 int bugsEaten;
	 
	 BOOL addFrog;
	 BOOL gameOver;
	 BOOL showBonus;
	 
	 ========== LILLY PAD STUFF ============
	 
	 float timer;
	 int landings;
	 int lastMovement;
	 BOOL moving;
	 BOOL touched;
	 BOOL growing;
	 CGPoint location;
	 CGPoint touchLoc;
	 GridLoc position;
	 
	 ============ FROG STUFF ===============
	 
	 float frameTimer;
	 float rotation;
	 float scale;
	 float blinkTimer;
	 float toungeTimer;
	 float arriveRate;
	 int orientation;
	 BOOL blinking;
	 BOOL hungry;
	 BOOL touched;
	 BOOL jumping;
	 BOOL eating;
	 BOOL turnAround;
	 BOOL showAlert;
	 BOOL arriving;
	 CGPoint toungeLocation;
	 CGPoint location;
	 CGPoint touchLoc;
	 GridLoc position;
	 GridLoc lastPosition;
	 
	 ============== BUG STUFF ===============
	 
	 float timer;
	 float frameTimer;
	 float xFlyRate;
	 float yFlyRate;
	 float rotation;
	 float scale;
	 BOOL eaten;
	 BOOL flying;
	 CGPoint location;
	 CGPoint flyLocation;
	 CGPoint moveTowards;
	 GridLoc position;
	 
	 
	 */
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/savedgame.dat"];
	
	if (gameMode == GAME_MODE_MENU) {
		// no game yet...
		return;
	}
	
	if (gameOver) {
		
		// dont save, and remove any saved game files that may exist
		
		NSFileManager* fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:fname]) {
			[fm removeItemAtPath:fname error:NULL];
		}
		
		return;
		
	}
	
	FILE *file;
	
	file = fopen([fname UTF8String], "w");
	
	if (gameMode != GAME_MODE_PAUSE) {
		savedGameMode = gameMode;
		gameMode = GAME_MODE_PAUSE;
	}
	
	fprintf(file, "%f %f %f\n", generalTimer, oneSecondCounter, bonusDisplayCounter);
	fprintf(file, "%d %d %d %d %d %d %d %d\n", gameMode, savedGameMode, secondsCounter, gameLengthCounter, minutesCounter, numSeconds, hungryFrogs, bugsEaten);
	fprintf(file, "%d %d %d\n", addFrogs, gameOver, showBonus);
	
	NSArray* lillyPads = [gameGrid getObjects];
	int howManyLillyPads = [lillyPads count];
	fprintf(file, "%d\n", howManyLillyPads);
	for (int i = 0; i < howManyLillyPads; i++) {
		PlatformSprite* p = [lillyPads objectAtIndex:i];
		fprintf(file, "%f %d %d %d %d %d ", [p timer], [p landings], [p lastMovement], [p moving], [p touched], [p growing]);
		fprintf(file, "%f %f %f %f %d %d\n", [p location].x, [p location].y, [p touchLoc].x, [p touchLoc].y, [p getGridPositionX], [p getGridPositionY]);
	}
	[lillyPads release];
	
	NSArray* frogs = [frogGrid getObjects];
	int howManyFrogs = [frogs count];
	fprintf(file, "%d\n", howManyFrogs);
	for (int i = 0; i < howManyFrogs; i++) {
		FrogSprite* f = [frogs objectAtIndex:i];
		fprintf(file, "%d %d %d %d %d %d %d %d %d ", [f orientation], [f blinking], [f hungry], [f touched], [f jumping], [f eating], [f turnAround], [f showAlert], [f arriving]);
		fprintf(file, "%f %f %f %f %f %f ", [f toungeLocation].x, [f toungeLocation].y, [f location].x, [f location].y, [f touchLoc].x, [f touchLoc].y);
		fprintf(file, "%d %d %d %d ", [f position].x, [f position].y, [f lastPosition].x, [f lastPosition].y);
		fprintf(file, "%f %f %f %f %f %f\n", [f frameTimer], [f rotation], [f scale], [f blinkTimer], [f toungeTimer], [f arriveRate]);
	}
	[frogs release];
	
	NSArray* bugs = [bugsGrid getObjects];
	int howManyBugs = [bugs count];
	fprintf(file, "%d\n", howManyBugs);
	for (int i = 0; i < howManyBugs; i++) {
		BugSprite* b = [bugs objectAtIndex:i];
		fprintf(file, "%f %f %f %f %f %f %d %d ", [b timer], [b frameTimer], [b xFlyRate], [b yFlyRate], [b rotation], [b scale], [b eaten], [b flying]);
		fprintf(file, "%f %f %f %f %f %f ", [b location].x, [b location].y, [b flyLocation].x, [b flyLocation].y, [b moveTowards].x, [b moveTowards].y);
		fprintf(file, "%d %d\n", [b position].x, [b position].y);
	}
	
	fclose(file);
	
}


- (void)loadGame {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/savedgame.dat"];
	
	FILE *file;
	
	file = fopen([fname UTF8String], "r");
	if (file == NULL) {
		return;
	}
	
	int gaddFrogs = 0;
	int ggameOver = 0;
	int gshowBonus = 0;
	
	fscanf(file, "%f %f %f\n", &generalTimer, &oneSecondCounter, &bonusDisplayCounter);
	fscanf(file, "%d %d %d %d %d %d %d %d\n", &gameMode, &savedGameMode, &secondsCounter, &gameLengthCounter, &minutesCounter, &numSeconds, &hungryFrogs, &bugsEaten);
	fscanf(file, "%d %d %d\n", &gaddFrogs, &ggameOver, &gshowBonus);
	addFrogs = gaddFrogs;
	gameOver = ggameOver;
	showBonus = gshowBonus;
	
	int howManyLillyPads = 0;
	fscanf(file, "%d\n", &howManyLillyPads);
	gameGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	for (int i = 0; i < howManyLillyPads; i++) {
		
		float ptimer = 0.0;
		int plandings = 0;
		int plastMovement = 0;
		int pmoving = NO;
		int ptouched = NO;
		int pgrowing = NO;
		CGPoint plocation = CGPointMake(0,0);
		CGPoint ptouchLoc = CGPointMake(0,0);
		GridLoc pgridLoc = {0, 0};
		
		fscanf(file, "%f %d %d %d %d %d ", &ptimer, &plandings, &plastMovement, &pmoving, &ptouched, &pgrowing);
		fscanf(file, "%f %f %f %f %d %d\n", &plocation.x, &plocation.y, &ptouchLoc.x, &ptouchLoc.y, &pgridLoc.x, &pgridLoc.y);
		
		PlatformSprite* p = [[PlatformSprite alloc] initWithPosition: pgridLoc.x: pgridLoc.y: lpTex: pgrowing];
		
		[p setTimer: ptimer];
		[p setLandings: plandings];
		[p setLastMovement: plastMovement];
		[p setMoving: pmoving];
		[p setTouched: ptouched];
		[p setGrowing: pgrowing];
		[p setLocation: plocation];
		[p setTouchLoc: ptouchLoc];
		
		[gameGrid addObjectAtPosition:pgridLoc.x :pgridLoc.y :p];
		
	}
	
	int howManyFrogs = 0;
	fscanf(file, "%d\n", &howManyFrogs);
	frogGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	for (int i = 0; i < howManyFrogs; i++) {
		
		int forientation = 0;
		int fblinking = NO;
		int fhungry = NO;
		int ftouched = NO;
		int fjumping = NO;
		int feating = NO;
		int fturnAround = NO;
		int fshowAlert = NO;
		int farriving = NO;
		CGPoint ftoungeLocation = CGPointMake(0,0);
		CGPoint flocation = CGPointMake(0,0);
		CGPoint ftouchLoc = CGPointMake(0,0);
		GridLoc fposition = {0,0};
		GridLoc flastPosition = {0,0};
		float fframeTimer = 0.0;
		float frotation = 0.0;
		float fscale = 1.0;
		float fblinkTimer = 0.0;
		float ftoungeTimer = 0.0;
		float farriveRate = 0.0;
		
		fscanf(file, "%d %d %d %d %d %d %d %d %d %f %f %f %f %f %f %d %d %d %d %f %f %f %f %f %f\n", &forientation, &fblinking, &fhungry, &ftouched, &fjumping, &feating, &fturnAround, &fshowAlert, &farriving, &ftoungeLocation.x, &ftoungeLocation.y, &flocation.x, &flocation.y, &ftouchLoc.x, &ftouchLoc.y, &fposition.x, &fposition.y, &flastPosition.x, &flastPosition.y, &fframeTimer, &frotation, &fscale, &fblinkTimer, &ftoungeTimer, &farriveRate);
		
		FrogSprite* f = [[FrogSprite alloc] initWithPosition:fposition.x :fposition.y :bfoTex :bfcTex :bfjTex :gfoTex :gfcTex :gfjTex :ftTex :faTex];
		
		[f setFrameTimer: fframeTimer];
		[f setRotation: frotation];
		[f setScale: fscale];
		[f setBlinkTimer: fblinkTimer];
		[f setToungeTimer: ftoungeTimer];
		[f setArriveRate: farriveRate];
		[f setOrientation: forientation];
		[f setBlinking: fblinking];
		[f setHungry: fhungry];
		[f setTouched: ftouched];
		[f setJumping: fjumping];
		[f setEating: feating];
		[f setTurnAround: fturnAround];
		[f setShowAlert: fshowAlert];
		[f setArriving: farriving];
		[f setToungeLocation: ftoungeLocation];
		[f setLocation: flocation];
		[f setTouchLoc: ftouchLoc];
		[f setPosition: fposition];
		[f setLastPosition: flastPosition];
		
		[frogGrid addObjectAtPosition:fposition.x :fposition.y :f];
		
	}
	
	int howManyBugs = 0;
	fscanf(file, "%d\n", &howManyBugs);
	bugsGrid = [[GameGrid alloc] initWithDimensions:GRID_WIDTH :GRID_HEIGHT];
	for (int i = 0; i < howManyBugs; i++) {
		
		float btimer = 0.0;
		float bframeTimer = 0.0;
		float bxFlyRate = 0.0;
		float byFlyRate = 0.0;
		float brotation = 0.0;
		float bscale = 0.0;
		int beaten = 0;
		int bflying = 0;
		CGPoint blocation = CGPointMake(0,0);
		CGPoint bflyLocation = CGPointMake(0,0);
		CGPoint bmoveTowards = CGPointMake(0,0);
		GridLoc bposition = {0,0};
		
		fscanf(file, "%f %f %f %f %f %f %d %d ", &btimer, &bframeTimer, &bxFlyRate, &byFlyRate, &brotation, &bscale, &beaten, &bflying);
		fscanf(file, "%f %f %f %f %f %f ", &blocation.x, &blocation.y, &bflyLocation.x, &bflyLocation.y, &bmoveTowards.x, &bmoveTowards.y);
		fscanf(file, "%d %d\n", &bposition.x, &bposition.y);
		
		BugSprite* b = [[BugSprite alloc] initWithPosition:bposition.x :bposition.y: bTex];
		//[bugs addObject:b];
		[bugsGrid addObjectAtPosition:bposition.x :bposition.y :b];
		
		[b setTimer: btimer];
		[b setFrameTimer: bframeTimer];
		[b setXFlyRate: bxFlyRate];
		[b setYFlyRate: byFlyRate];
		[b setRotation: brotation];
		[b setScale: bscale];
		[b setEaten: beaten];
		[b setFlying: bflying];
		[b setLocation: blocation];
		[b setFlyLocation: bflyLocation];
		[b setMoveTowards: bmoveTowards];
		
	}
	
	fclose(file);
	
}

- (int)loadHighScore {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/highscore.dat"];
	
	FILE *file;
	
	int hs = 0;
	
	file = fopen([fname UTF8String], "r");
	if (file == NULL) {
		return hs;
	}
	
	fscanf(file, "%d", &hs);
	fclose(file);
	
	return hs;	
	
}

- (void)saveHighScore:(int) hs {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString* fname = [documentsDirectory stringByAppendingString:@"/highscore.dat"];
	FILE *file;
	
	file = fopen([fname UTF8String], "w");
	
	fprintf(file, "%d", hs);
	fclose(file);
	
}

- (void)dealloc {
	
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
