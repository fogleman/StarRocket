//
//  TutorialScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialScene.h"

@implementation TutorialScene

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	
	TutorialScene* layer = [TutorialScene node];
	[scene addChild:layer];
	
	return scene;
}

- (id)init {
	self = [super init];
	if (self) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tutorial-background.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tutorial-grid.plist"];
		
		preloadResources();
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"tutorial-grid.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
		
		contentLayer = [CCLayer node];
		[self addChild:contentLayer];
		
		[self createWindow];
		[self createMenu];
		[self showPage:1];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)createBackground {
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"tutorial-grid.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
}

- (void)createWindow {
	CCSpriteBatchNode* windowBatch = [CCSpriteBatchNode batchNodeWithFile:@"tutorial-background.pvr.ccz"];
	[self addChild:windowBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"tutorial-background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[windowBatch addChild:sprite];
}

- (void)createMenu {
	CGPoint point;
	int offset = 39;
	float radius = 32;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	point = ccp(size.width - offset, offset - 2);
	nextButton = [Button buttonWithPosition:point radius:radius normalName:@"button-next.png" selectedName:@"button-next-hi.png"];
	[self addChild:nextButton];
	
	point = ccp(offset, offset - 2);
	backButton = [Button buttonWithPosition:point radius:radius normalName:@"button-back.png" selectedName:@"button-back-hi.png"];
	[self addChild:backButton];
	
	point = ccp(offset, size.height - offset);
	menuButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[self addChild:menuButton];
}

- (void)showPage:(int)page {
	if (page < 1 || page > 6) {
		[self onMenu];
		return;
	}
	if (page == currentPage) {
		return;
	}
	CGSize size = [[CCDirector sharedDirector] winSize];
	float width = size.width / 2;
	BOOL forward = (page > currentPage);
	CGPoint point;
	CGPoint a = ccp(-width, size.height / 2);
	CGPoint b = ccp(width, size.height / 2);
	CGPoint c = ccp(3 * width, size.height / 2);
	float duration = 0.5f;
	// move current sprite out then delete it
	if (contentSprite) {
		if ([contentSprite numberOfRunningActions]) {
			return;
		}
		if (forward) {
			point = a;
		}
		else {
			point = c;
		}
		id action1 = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:duration position:point] rate:2];
		id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)];
		id action3 = [CCSequence actions:action1, action2, nil];
		[contentSprite runAction:action3];
	}
	// move new sprite in
	NSString* name = [NSString stringWithFormat:@"tutorial%d.png", page];
	contentSprite = [CCSprite spriteWithFile:name];
	if (forward) {
		contentSprite.position = c;
	}
	else {
		contentSprite.position = a;
	}
	if ([[CCDirector sharedDirector] contentScaleFactor] == 1) {
		contentSprite.scale = 0.5f;
	}
	id action1 = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:duration position:b] rate:2];
	[contentSprite runAction:action1];
	[contentLayer addChild:contentSprite];
	// finish
	currentPage = page;
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)removeNode:(CCNode*)node {
	[contentLayer removeChild:node cleanup:YES];
}

- (void)onMenu {
	CCScene* scene = [MenuScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onBack {
	[self showPage:currentPage - 1];
}

- (void)onNext {
	[self showPage:currentPage + 1];
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	
	if ([menuButton handleTouchType:type point:point]) {
		[self onMenu];
		return;
	}
	if ([nextButton handleTouchType:type point:point]) {
		[self onNext];
		return;
	}
	if ([backButton handleTouchType:type point:point]) {
		[self onBack];
		return;
	}
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch* touch in touches) {
		[self handleTouch:touch type:kBegan];
	}
}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch* touch in touches) {
		[self handleTouch:touch type:kMoved];
	}
}

- (void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch* touch in touches) {
		[self handleTouch:touch type:kEnded];
	}
}

- (void)ccTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch* touch in touches) {
		[self handleTouch:touch type:kCancelled];
	}
}

@end
