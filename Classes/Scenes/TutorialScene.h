//
//  TutorialScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MenuScene.h"
#import "Button.h"
#import "Util.h"

@interface TutorialScene : CCLayer {
	CCSpriteBatchNode* backgroundBatch;
	CCLayer* contentLayer;
	CCSprite* contentSprite;
	int currentPage;
	Button* menuButton;
	Button* backButton;
	Button* nextButton;
}

+ (CCScene*)scene;

- (void)createBackground;
- (void)createWindow;
- (void)createMenu;

- (void)showPage:(int)page;
- (void)removeNode:(CCNode*)node;

- (void)onMenu;
- (void)onBack;
- (void)onNext;

- (void)handleTouch:(UITouch*)touch type:(int)type;

@end
