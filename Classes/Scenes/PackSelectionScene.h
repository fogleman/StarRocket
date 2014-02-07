//
//  PackSelectionScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 2/23/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Button.h"
#import "Pack.h"
#import "MenuScene.h"
#import "LevelSelectionScene.h"

@interface PackSelectionScene : CCLayer {
	CCLayer* contentLayer;
	CCNode* contentNode;
	Button* menuButton;
	Button* backButton;
	Button* nextButton;
	Button* playButton;
	int currentPage;
}

+ (CCScene*)scene;

- (void)createWindow;
- (void)createMenu;
- (void)createSprites;

- (void)showPage:(int)page;
- (CCNode*)createContentNode:(int)page;
- (void)removeNode:(CCNode*)node;

- (void)onMenu;
- (void)onBack;
- (void)onNext;
- (void)onPlay;

- (void)handleTouch:(UITouch*)touch type:(int)type;

@end
