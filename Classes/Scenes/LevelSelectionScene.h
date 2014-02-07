//
//  LevelSelectionScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "PackSelectionScene.h"
#import "ScrollView.h"
#import "Button.h"
#import "GameScene.h"
#import "Pack.h"
#import "Util.h"

@interface LevelSelectionScene : CCLayer {
	Pack* pack;
	CCLayer* scrollLayer;
	ScrollView* scrollView;
	CCSpriteBatchNode* scrollBatch;
	CCSpriteBatchNode* backgroundBatch;
	CCSpriteBatchNode* hudBatch;
	Button* backButton;
	Button* playButton;
	CCArray* buttons;
	CCSprite* thumbSprite;
	CCSprite* selectionSprite;
	int selectedLevel;
	int scrollHeight;
}

+ (CCScene*)sceneWithPack:(Pack*)_pack;

- (id)initWithPack:(Pack*)_pack;
- (void)createBackground;
- (void)createScrollView;
- (void)createSprites;
- (void)createThumb:(int)number;
- (void)createMenu;
- (void)addLabelWithString:(NSString*)string center:(CGPoint)center size:(CGSize)size batch:(CCSpriteBatchNode*)batch;
- (void)onBack;
- (void)onPlay;
- (void)onSelect:(int)number pan:(BOOL)pan;

@end
