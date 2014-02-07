//
//  MenuScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"

@implementation MenuScene

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	
	MenuScene* layer = [MenuScene node];
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
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu-background.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu-objects.plist"];
		
		preloadResources();
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-image.pvr.ccz"];
		[self addChild:backgroundBatch];
		
		starBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-objects.pvr.ccz"];
		[self addChild:starBatch];
		
		imageBatch = [CCSpriteBatchNode batchNodeWithFile:@"menu-background.pvr.ccz"];
		[self addChild:imageBatch];
		
		buttonBatch = [CCSpriteBatchNode batchNodeWithFile:@"menu-objects.pvr.ccz"];
		[self addChild:buttonBatch];
		
		[self createBackground];
		createStars(150, starBatch);
		[self createButtons];
		
		self.isTouchEnabled = YES;
		[self scheduleUpdate];
	}
	return self;
}

- (void)update:(ccTime)dt {
	float angle = RADIANS(200);
	float velocity = 15;
	CGPoint offset = ccp(cosf(angle) * velocity * dt, sinf(angle) * velocity * dt);
	moveStars(offset, starBatch);
}

- (void)createBackground {
	CCSprite* sprite;
	
	sprite = [CCSprite spriteWithSpriteFrameName:@"background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
	
	sprite = [CCSprite spriteWithSpriteFrameName:@"menu-background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[imageBatch addChild:sprite];
}

- (void)createButtons {
	CGSize size = [[CCDirector sharedDirector] winSize];
	CGPoint point;
	NSString* normal;
	NSString* selected;
	float radius = 60;
	
	point = ccp(size.width * 1 / 5, 40);
	normal = @"menu-button-play.png";
	selected = @"menu-button-play-hi.png";
	playButton = [Button buttonWithPosition:point radius:radius normalName:normal selectedName:selected];
	[buttonBatch addChild:playButton];
	
	point = ccp(size.width / 2, 40);
	normal = @"menu-button-tutorial.png";
	selected = @"menu-button-tutorial-hi.png";
	tutorialButton = [Button buttonWithPosition:point radius:radius normalName:normal selectedName:selected];
	[buttonBatch addChild:tutorialButton];
	
	point = ccp(size.width * 4 / 5, 40);
	normal = @"menu-button-options.png";
	selected = @"menu-button-options-hi.png";
	optionsButton = [Button buttonWithPosition:point radius:radius normalName:normal selectedName:selected];
	[buttonBatch addChild:optionsButton];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"menu-star.png"];
	sprite.position = ccp(231, 116);
	[buttonBatch addChild:sprite];
	
	id action1 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:-360] rate:2];
	id action2 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:360] rate:2];
	id action3 = [CCSequence actions:action1, action2, nil];
	id action4 = [CCRepeat actionWithAction:action3 times:5];
	id action5 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:-180*5] rate:2];
	id action6 = [CCSequence actions:action4, action5, action2, nil];
	id action7 = [CCRepeatForever actionWithAction:action6];
	[sprite runAction:action7];
}

- (void)onPlay {
	CCScene* scene = [PackSelectionScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onTutorial {
	CCScene* scene = [TutorialScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onOptions {
	CCScene* scene = [OptionsScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:nil];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	
	// Buttons
	if ([playButton handleTouchType:type point:point]) {
		[self onPlay];
		return;
	}
	if ([tutorialButton handleTouchType:type point:point]) {
		[self onTutorial];
		return;
	}
	if ([optionsButton handleTouchType:type point:point]) {
		[self onOptions];
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
