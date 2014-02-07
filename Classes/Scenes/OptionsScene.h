//
//  OptionsScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 1/15/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Button.h"
#import "MenuScene.h"
#import "CreditsScene.h"
#import "Util.h"

@interface OptionsScene : CCLayer {
	CCSpriteBatchNode* backgroundBatch;
	Button* menuButton;
	Button* infoButton;
	Button* soundButton;
	Button* joystickButton;
	Button* ghostButton;
	Button* resetButton;
}

+ (CCScene*)scene;

- (void)createBackground;
- (void)createWindow;
- (void)createMenu;
- (void)createButtons;
- (void)updateLabels;

- (void)onMenu;
- (void)onInfo;
- (void)onSound;
- (void)onJoystick;
- (void)onGhost;
- (void)onReset;

- (void)handleTouch:(UITouch*)touch type:(int)type;

@end
