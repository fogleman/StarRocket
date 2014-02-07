//
//  TempAppDelegate.h
//  Temp
//
//  Created by Michael Fogleman on 12/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, MFMailComposeViewControllerDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

- (void)playMusic;
- (void)sendGhostFiles;
- (void)showAlert;

@end
