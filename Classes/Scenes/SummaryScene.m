//
//  SummaryScene.m
//  GravityAssist
//
//  Created by Michael Fogleman on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SummaryScene.h"

@implementation SummaryScene

+ (CCScene*)sceneWithGameScene:(GameScene*)gameScene {
	CCScene* scene = [CCScene node];
	
	SummaryScene* layer = [[[SummaryScene alloc] initWithGameScene:gameScene] autorelease];
	[scene addChild:layer];
	
	return scene;
}

- (id)initWithGameScene:(GameScene*)gameScene {
	self = [super init];
	if (self) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-image.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-objects.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-window.plist"];
		
		preloadResources();
		
		state = gameScene.state;
		level = gameScene.level;
		millisElapsed = gameScene.millisElapsed;
		pack = getPackForLevel(level);
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-image.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
		
		starBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-objects.pvr.ccz"];
		[self addChild:starBatch];
		createStars(150, starBatch);
		
		[self createWindow];
		[self createMenu];
		[self createText];
		
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
	CCSpriteBatchNode* windowBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-window.pvr.ccz"];
	[self addChild:windowBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"background-window.png"];
	sprite.anchorPoint = ccp(0, 0);
	[windowBatch addChild:sprite];
}

- (void)createMenu {
	CGPoint point;
	int offset = 39;
	float radius = 32;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	if (state == kStateWon) {
		nextEnabled = YES;
		
		point = ccp(size.width - offset, offset - 2);
		nextButton = [Button buttonWithPosition:point radius:radius normalName:@"button-next.png" selectedName:@"button-next-hi.png"];
		[self addChild:nextButton];
		
		point = ccp(size.width - offset, size.height - offset);
		restartButton = [Button buttonWithPosition:point radius:radius normalName:@"button-restart.png" selectedName:@"button-restart-hi.png"];
		[self addChild:restartButton];
	}
	else {
		if (isLevelEnabled(level + 1)) {
			nextEnabled = YES;
			
			point = ccp(size.width - offset, size.height - offset);
			nextButton = [Button buttonWithPosition:point radius:radius normalName:@"button-next.png" selectedName:@"button-next-hi.png"];
			[self addChild:nextButton];
		}
		else {
			nextEnabled = NO;
			
			point = ccp(size.width - offset, size.height - offset);
			nextButton = [Button buttonWithPosition:point radius:radius normalName:@"button-next-disabled.png" selectedName:@"button-next-disabled.png"];
			[self addChild:nextButton];
		}
		
		point = ccp(size.width - offset, offset - 2);
		restartButton = [Button buttonWithPosition:point radius:radius normalName:@"button-restart.png" selectedName:@"button-restart-hi.png"];
		[self addChild:restartButton];
	}
	
	point = ccp(offset, size.height - offset);
	menuButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[self addChild:menuButton];
}

- (void)createText {
	NSString* string;
	CCSprite* sprite;
	CCLabelBMFont* label;
	int offset;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// Header
	if (state == kStateWon) {
		string = @"text-complete.png";
		offset = 45;
	}
	else {
		string = @"text-failed.png";
		offset = 0;
	}
	sprite = [CCSprite spriteWithSpriteFrameName:string];
	sprite.position = ccp(size.width / 2, size.height - 80);
	[self addChild:sprite];
	
	// Level
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-level.png"];
	sprite.position = ccp(size.width / 2, size.height - 125);
	[self addChild:sprite];
	
	string = [NSString stringWithFormat:@"%d", level - pack.start + 1];
	label = [CCLabelBMFont labelWithString:string fntFile:@"hud-numbers.fnt"];
	label.position = ccp(size.width / 2, size.height - 160);
	label.opacity = 192;
	[self addChild:label];
	
	// This Time
	if (state == kStateWon) {
		sprite = [CCSprite spriteWithSpriteFrameName:@"text-time.png"];
		sprite.position = ccp(size.width / 2 - offset, size.height - 190);
		[self addChild:sprite];
		
		string = [NSString stringWithFormat:@"%.2f", (float)millisElapsed / kTimeDivider];
		label = [CCLabelBMFont labelWithString:string fntFile:@"hud-numbers.fnt"];
		label.position = ccp(size.width / 2 - offset, size.height - 225);
		label.opacity = 192;
		[self addChild:label];
		
		string = [NSString stringWithFormat:@"stars%d.png", getTimeStarCount(level, millisElapsed)];
		sprite = [CCSprite spriteWithSpriteFrameName:string];
		sprite.position = ccp(size.width / 2 - offset, size.height - 250);
		[self addChild:sprite];
	}
	
	// Best Time
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-best.png"];
	sprite.position = ccp(size.width / 2 + offset, size.height - 190);
	[self addChild:sprite];
	
	int bestTime = getBestTime(level);
	if (bestTime > 0) {
		string = [NSString stringWithFormat:@"%.2f", (float)bestTime / kTimeDivider];
	}
	else {
		string = @"n/a";
	}
	label = [CCLabelBMFont labelWithString:string fntFile:@"hud-numbers.fnt"];
	label.position = ccp(size.width / 2 + offset, size.height - 225);
	label.opacity = 192;
	[self addChild:label];
	
	int count = getTimeStarCount(level, -1);
	if (count >= 1 && count <= 3) {
		string = [NSString stringWithFormat:@"stars%d.png", count];
		sprite = [CCSprite spriteWithSpriteFrameName:string];
		sprite.position = ccp(size.width / 2 + offset, size.height - 250);
		[self addChild:sprite];
	}
}

- (void)update:(ccTime)dt {
	float angle = RADIANS(200);
	float velocity = 15;
	CGPoint offset = ccp(cosf(angle) * velocity * dt, sinf(angle) * velocity * dt);
	moveStars(offset, starBatch);
}

- (void)onMenu {
	CCScene* scene = [LevelSelectionScene sceneWithPack:pack];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onRestart {
	CCScene* scene = [GameScene sceneWithLevel:level];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onNext {
	if (!nextEnabled) {
		return;
	}
	CCScene* scene = [GameScene sceneWithLevel:level + 1];
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
	if ([nextButton handleTouchType:type point:point]) {
		[self onNext];
		return;
	}
	if ([restartButton handleTouchType:type point:point]) {
		[self onRestart];
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

- (void)dealloc {
	NSLog(@"SummaryScene dealloc");
	[super dealloc];
}

@end
