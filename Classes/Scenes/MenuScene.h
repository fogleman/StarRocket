//
//  MenuScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PackSelectionScene.h"
#import "TutorialScene.h"
#import "OptionsScene.h"
#import "Button.h"
#import "Pack.h"
#import "Util.h"

@interface MenuScene : CCLayer {
	CCSpriteBatchNode* backgroundBatch;
	CCSpriteBatchNode* starBatch;
	CCSpriteBatchNode* imageBatch;
	CCSpriteBatchNode* buttonBatch;
	Button* playButton;
	Button* optionsButton;
	Button* tutorialButton;
}

+ (CCScene*)scene;

- (void)createBackground;
- (void)createButtons;

- (void)onPlay;
- (void)onTutorial;
- (void)onOptions;

- (void)handleTouch:(UITouch*)touch type:(int)type;

@end
