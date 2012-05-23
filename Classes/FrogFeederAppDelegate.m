//
//  FrogFeederAppDelegate.m
//  FrogFeeder
//
//  Created by Casey Leonard on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FrogFeederAppDelegate.h"
#import "EAGLView.h"

@implementation FrogFeederAppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[glView pause];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	[glView saveGame];
	
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end
