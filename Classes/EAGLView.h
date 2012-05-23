//
//  EAGLView.h
//  FrogFeeder
//
//  Created by Casey Leonard on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <Foundation/NSFileManager.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <AudioToolbox/AudioToolbox.h>
#import "Texture2D.h"
#import "Image.h"
#import "PlatformSprite.h"
#import "FrogSprite.h"
#import "BugSprite.h"
#import "SplashSprite.h"
#import "SpriteSheet.h"
#import "GridStuff.h"
#import "GameGrid.h"
#import "Defines.h"
#import "oalPlayback.h"

/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView <UIAccelerometerDelegate> {
    
@private
	
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
	
	/* State to define if OGL has been initialised or not */
	BOOL glInitialised;
	
	/* Bounds of the current screen */
	CGRect screenBounds;
	
	NSTimer *gameLoopTimer;
	
	/* Time since the last frame was rendered */
	CFTimeInterval lastTime;
	
	SystemSoundID frogTap;
	SystemSoundID frogSwipe;
	SystemSoundID splash;
	SystemSoundID lillyPadTap;
	SystemSoundID lillyPadSwipe;
	SystemSoundID eat;
	SystemSoundID buttonClickStart;
	SystemSoundID buttonClickEnd;
	
	Texture2D* lpTex;
	Texture2D* bTex;
	Texture2D* bfoTex;
	Texture2D* bfcTex;
	Texture2D* bfjTex;
	Texture2D* gfoTex;
	Texture2D* gfcTex;
	Texture2D* gfjTex;
	Texture2D* ftTex;
	Texture2D* faTex;
	
	SpriteSheet* ss;
	SpriteSheet* numberSheet;
	SpriteSheet* hsNumberSheet;
	Image* scoreLegend;
	
	Image* water;
	Image* splashScreen;
	
	Image* creditsScreen;
	Image* credits[7];
	
	Image* howToScreen;
	Image* frogOnLillyPad;
	float frogRotation1;
	float frogRotation2;
	
	Image* playButton;
	Image* pauseButton;
	
	Image* gameOverImage;
	Image* continueImage;
	
	Image* bonusX2;
	Image* bonusX3;
	Image* bonusX4;
	
	Image* bonusShowing;
	
	SpriteSheet* ripples;
	
	BOOL savedGameExists;
	BOOL promptToContinue;
	BOOL showCredits;
	BOOL showInstructions;
	float creditsX;
	
	int highscore;
	
	BOOL fadeout;
	oalPlayback* playback;
	
	int buttonPressed;
	
	CGRect paRect;
	CGRect menuRect;
	CGRect playRect;
	CGRect creditsRect;
	CGRect howRect;
	CGRect menu1Rect;
	CGRect menu2Rect;
	CGRect yesRect;
	CGRect noRect;
	CGRect pgRect;

	
	// =============================== VARIABLES THAT ARE PART OF THE GAME STATE ================
	
	GameGrid* gameGrid;
	GameGrid* frogGrid;
	GameGrid* bugsGrid;
	
	NSMutableArray* splashes;
	
	NSMutableArray* bugsToRemove;
	
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
	int addFrogs;
	
	BOOL gameOver;
	BOOL showBonus;
	
}

- (void)firstTimeInit;
- (void)renderScene;
- (void)mainGameLoop;
- (void)startAnimation;
- (void)createBug;
- (void)createFrog;
- (void)createLillyPad;
- (void)drawScoreBoard;
- (void)drawScoreBoard: (BOOL)forMenu;
- (void)setFrogAlert: (FrogSprite*) f;
- (void)saveGame;
- (void)loadGame;
- (void)deleteSavedGame;
- (int)loadHighScore;
- (void)saveHighScore: (int)hs;
- (void)pause;
- (void)resume;


@end
