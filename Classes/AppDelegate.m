//
//  TempAppDelegate.m
//  Temp
//
//  Created by Michael Fogleman on 12/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "GameConfig.h"
#import "MenuScene.h"
#import "RootViewController.h"
#import "SimpleAudioEngine.h"
#import "Pack.h"
#import "Util.h"

@implementation AppDelegate

@synthesize window;

- (void)playMusic {
	SimpleAudioEngine* engine = [SimpleAudioEngine sharedEngine];
	if (engine) {
		[engine preloadBackgroundMusic:@"song1.mp3"];
		if (engine.willPlayBackgroundMusic) {
			engine.backgroundMusicVolume = 0.4f;
		}
		[engine playBackgroundMusic:@"song1.mp3"];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication*)application {
//	[self playMusic];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink]) {
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	}
	
	CCDirector *director = [CCDirector sharedDirector];
	
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
					   ];
	[glView setMultipleTouchEnabled:YES];
	[director setOpenGLView:glView];
	
	if (![director enableRetinaDisplay:YES]) {
		// Retina display not supported
	}
	
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
//	[director setDisplayFPS:YES];
	
	[viewController setView:glView];
	[window addSubview: viewController.view];
	[window makeKeyAndVisible];
	
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	preloadResources();
	
	for (Pack* pack in [Pack getPacks]) {
		for (int level = pack.start; level <= pack.end; level++) {
			int time = getBestTime(level);
			if (time) {
				NSLog(@"case %d: return %d;", level, time);
			}
		}
	}
	
	NSLog(@"Device Model: %@", getDeviceModelName());
	
	if (shouldShowAlert()) {
		setAlertShown(YES);
		[self showAlert];
	}
	
	CCScene* scene = [MenuScene scene];
	[[CCDirector sharedDirector] runWithScene:scene];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"applicationDidReceiveMemoryWarning");
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[viewController release];
	[window release];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}



- (void)showAlert {
	NSString* title;
	NSString* message;
#ifdef LITE
	title = @"Want More Levels?";
	message = @"You're doing well! Would you like to get the full version of Star Rocket that has many more levels?";
#else
	title = @"Review Star Rocket?";
	message = @"You're doing well! Would you like to review Star Rocket in the App Store to let others know what you think?";
#endif
	UIAlertView* view = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Sure!", nil];
	[view show];
	[view release];
}

- (void)alertView:(UIAlertView*)view clickedButtonAtIndex:(NSInteger)index {
	if (index) {
#ifdef LITE
		NSString* url = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=419027792&mt=8"];
#else
		NSString* url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=419027792"];
#endif
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error
{
	[viewController dismissModalViewControllerAnimated:YES];
}

- (void)sendGhostFiles {
//	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//	controller.mailComposeDelegate = self;
//	[controller setSubject:@"Ghost Files"];
//	[controller setMessageBody:@"" isHTML:NO];
//	
//	int count = [[LevelManager sharedManager] count];
//	for (int level = 1; level <= count; level++) {
//		NSString* key = [NSString stringWithFormat:@"Ghost%d", level];
//		NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
//		if (data) {
//			[controller addAttachmentData:data mimeType:@"text/plain" fileName:key];
//		}
//	}
//	
//	[viewController presentModalViewController:controller animated:YES];
//	[controller release];
}

@end
