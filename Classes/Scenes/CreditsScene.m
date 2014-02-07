//
//  CreditsScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 1/26/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import "CreditsScene.h"

@implementation CreditsScene

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	
	CreditsScene* layer = [CreditsScene node];
	[scene addChild:layer];
	
	return scene;
}

- (id)init {
	self = [super init];
	if (self) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-image.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-objects.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"credits-background.plist"];
		
		preloadResources();
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-image.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
		
		starBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-objects.pvr.ccz"];
		[self addChild:starBatch];
		createStars(150, starBatch);
		
		[self createWindow];
		[self createMenu];
		
		self.isTouchEnabled = YES;
		[self scheduleUpdate];
	}
	return self;
}

- (void)createBackground {
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
}

- (void)createWindow {
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCSpriteBatchNode* windowBatch = [CCSpriteBatchNode batchNodeWithFile:@"credits-background.pvr.ccz"];
	[self addChild:windowBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"credits-background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[windowBatch addChild:sprite];
	
	sprite = [CCSprite spriteWithFile:@"credits.png"];
	sprite.position = ccp(size.width / 2, size.height / 2);
	[self addChild:sprite];
}

- (void)createMenu {
	CGPoint point;
	int offset = 39;
	float radius = 32;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	point = ccp(offset, size.height - offset);
	menuButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[self addChild:menuButton];
}

- (void)update:(ccTime)dt {
	float angle = RADIANS(200);
	float velocity = 15;
	CGPoint offset = ccp(cosf(angle) * velocity * dt, sinf(angle) * velocity * dt);
	moveStars(offset, starBatch);
}

- (void)onMenu {
	CCScene* scene = [OptionsScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	
	if ([menuButton handleTouchType:type point:point]) {
		[self onMenu];
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
