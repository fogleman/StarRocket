//
//  OptionsScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 1/15/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import "OptionsScene.h"

@implementation OptionsScene

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	
	OptionsScene* layer = [OptionsScene node];
	[scene addChild:layer];
	
	return scene;
}

- (id)init {
	self = [super init];
	if (self) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tutorial-grid.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"options-background.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"options-objects.plist"];
		
		preloadResources();
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"tutorial-grid.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
		
		[self createWindow];
		[self createMenu];
		[self createButtons];
		[self updateLabels];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)createBackground {
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"tutorial-grid.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
}

- (void)createWindow {
	CCSpriteBatchNode* windowBatch = [CCSpriteBatchNode batchNodeWithFile:@"options-background.pvr.ccz"];
	[self addChild:windowBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"options-background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[windowBatch addChild:sprite];
}

- (void)createMenu {
	CGPoint point;
	int offset = 39;
	float radius = 32;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	point = ccp(offset, size.height - offset);
	menuButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[self addChild:menuButton];
	
	point = ccp(size.width - offset, size.height - offset);
	infoButton = [Button buttonWithPosition:point radius:radius normalName:@"button-info.png" selectedName:@"button-info-hi.png"];
	[self addChild:infoButton];
}

- (void)createButtons {
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	float spacing = 60;
	float y = size.height / 2 + spacing * 1.5f;
	GLubyte opacity = 192;
	
	soundButton = [Button buttonWithPosition:ccp(size.width / 2, y) radius:0 normalName:@"button-sound-off.png" selectedName:@"button-sound-off.png"];
	soundButton.rect = CGRectMake(size.width / 2 - 90, y - 30, 180, 60);
	soundButton.normalOpacity = opacity;
	[self addChild:soundButton];
	y -= spacing;
	
	joystickButton = [Button buttonWithPosition:ccp(size.width / 2, y) radius:0 normalName:@"button-joystick-left.png" selectedName:@"button-joystick-left.png"];
	joystickButton.rect = CGRectMake(size.width / 2 - 90, y - 30, 180, 60);
	joystickButton.normalOpacity = opacity;
	[self addChild:joystickButton];
	y -= spacing;
	
	ghostButton = [Button buttonWithPosition:ccp(size.width / 2, y) radius:0 normalName:@"button-ghost-off.png" selectedName:@"button-ghost-off.png"];
	ghostButton.rect = CGRectMake(size.width / 2 - 90, y - 30, 180, 60);
	ghostButton.normalOpacity = opacity;
	[self addChild:ghostButton];
	y -= spacing;
	
	resetButton = [Button buttonWithPosition:ccp(size.width / 2, y) radius:0 normalName:@"button-reset-game.png" selectedName:@"button-reset-game.png"];
	resetButton.rect = CGRectMake(size.width / 2 - 90, y - 30, 180, 60);
	resetButton.normalOpacity = opacity;
	[self addChild:resetButton];
	y -= spacing;
}

- (void)updateLabels {
	if (getSoundDisabled()) {
		soundButton.normalName = @"button-sound-off.png";
		soundButton.selectedName = @"button-sound-off.png";
	}
	else {
		soundButton.normalName = @"button-sound-on.png";
		soundButton.selectedName = @"button-sound-on.png";
	}
	
	if (getSwapJoystick()) {
		joystickButton.normalName = @"button-joystick-right.png";
		joystickButton.selectedName = @"button-joystick-right.png";
	}
	else {
		joystickButton.normalName = @"button-joystick-left.png";
		joystickButton.selectedName = @"button-joystick-left.png";
	}
	
	if (getGhostEnabled()) {
		ghostButton.normalName = @"button-ghost-on.png";
		ghostButton.selectedName = @"button-ghost-on.png";
	}
	else {
		ghostButton.normalName = @"button-ghost-off.png";
		ghostButton.selectedName = @"button-ghost-off.png";
	}
	
	[soundButton setFrame];
	[joystickButton setFrame];
	[ghostButton setFrame];
	[resetButton setFrame];
}

- (void)onMenu {
	CCScene* scene = [MenuScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onInfo {
	CCScene* scene = [CreditsScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onSound {
	setSoundDisabled(!getSoundDisabled());
	[self updateLabels];
}

- (void)onJoystick {
	setSwapJoystick(!getSwapJoystick());
	[self updateLabels];
}

- (void)onGhost {
	setGhostEnabled(!getGhostEnabled());
	[self updateLabels];
}

- (void)onReset {
	UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Reset Game?" message:@"Are you sure you want to reset the game? All saved progress will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset Game", nil];
	[view show];
	[view release];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		resetGame();
	}
	[self updateLabels];
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	
	if ([menuButton handleTouchType:type point:point]) {
		[self onMenu];
		return;
	}
	if ([infoButton handleTouchType:type point:point]) {
		[self onInfo];
		return;
	}
	if ([soundButton handleTouchType:type point:point]) {
		[self onSound];
		return;
	}
	if ([joystickButton handleTouchType:type point:point]) {
		[self onJoystick];
		return;
	}
	if ([ghostButton handleTouchType:type point:point]) {
		[self onGhost];
		return;
	}
	if ([resetButton handleTouchType:type point:point]) {
		[self onReset];
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
