//
//  SummaryScene.h
//  GravityAssist
//
//  Created by Michael Fogleman on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Button.h"
#import "GameScene.h"
#import "LevelSelectionScene.h"
#import "Pack.h"
#import "Util.h"

@class GameScene;

@interface SummaryScene : CCLayer {
	Pack* pack;
	int state;
	int level;
	int millisElapsed;
	BOOL nextEnabled;
	
	CCSpriteBatchNode* backgroundBatch;
	CCSpriteBatchNode* starBatch;
	Button* menuButton;
	Button* nextButton;
	Button* restartButton;
}

+ (CCScene*)sceneWithGameScene:(GameScene*)gameScene;

- (id)initWithGameScene:(GameScene*)gameScene;

- (void)createBackground;
- (void)createWindow;
- (void)createMenu;
- (void)createText;

- (void)onMenu;
- (void)onRestart;
- (void)onNext;

- (void)handleTouch:(UITouch*)touch type:(int)type;

@end
