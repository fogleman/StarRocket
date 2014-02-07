//
//  PackSelectionScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 2/23/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import "PackSelectionScene.h"

@implementation PackSelectionScene

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	
	PackSelectionScene* layer = [PackSelectionScene node];
	[scene addChild:layer];
	
	return scene;
}

- (id)init {
	self = [super init];
	if (self) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pack-background.plist"];
		
		preloadResources();
				
		contentLayer = [CCLayer node];
		[self addChild:contentLayer];
		
		[self createWindow];
		[self createMenu];
		[self createSprites];
		
		currentPage = -1;
		
		// select most recent pack
		int page = 0;
		int level = getMostRecentLevel();
		Pack* pack = getPackForLevel(level);
		NSArray* packs = [Pack getPacks];
		for (unsigned int index = 0; index < [packs count]; index++) {
			if (pack == [packs objectAtIndex:index]) {
				page = index;
			}
		}
		[self showPage:page];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)createWindow {
	CCSpriteBatchNode* windowBatch = [CCSpriteBatchNode batchNodeWithFile:@"pack-background.pvr.ccz"];
	[self addChild:windowBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"pack-background.png"];
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
	
	point = ccp(size.width - offset, size.height - offset);
	playButton = [Button buttonWithPosition:point radius:radius normalName:@"button-play.png" selectedName:@"button-play-hi.png"];
	[self addChild:playButton];
}

- (void)createSprites {
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"text-pack-select.png"];
	sprite.anchorPoint = ccp(0.5f, 1);
	sprite.position = ccp(size.width / 2, size.height - 35);
	[self addChild:sprite];
}

- (void)showPage:(int)page {
	int count = (int)[[Pack getPacks] count];
	if (page < 0 || page >= count) {
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
	if (contentNode) {
		if ([contentNode numberOfRunningActions]) {
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
		[contentNode runAction:action3];
	}
	// move new sprite in
	contentNode = [self createContentNode:page];
	if (forward) {
		contentNode.position = c;
	}
	else {
		contentNode.position = a;
	}
	id action1 = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:duration position:b] rate:2];
	[contentNode runAction:action1];
	[contentLayer addChild:contentNode];
	// disable buttons
	if (page == 0) {
		[backButton setFrame:@"button-back-disabled.png"];
	}
	else {
		[backButton setFrame];
	}
	if (page == count - 1) {
		[nextButton setFrame:@"button-next-disabled.png"];
	}
	else {
		[nextButton setFrame];
	}
	// finish
	currentPage = page;
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (CCNode*)createContentNode:(int)page {
	CGSize size = [[CCDirector sharedDirector] winSize];
	Pack* pack = [[Pack getPacks] objectAtIndex:page];
	CCLayer* layer = [CCLayer node];
	
	NSString* name = [NSString stringWithFormat:@"pack%d.png", pack.start];
	CCSprite* sprite = [CCSprite spriteWithFile:name];
	if ([[CCDirector sharedDirector] contentScaleFactor] == 1) {
		sprite.scale = 0.5f;
	}
	sprite.position = ccp(0, 20);
	[layer addChild:sprite];
	
	CCLabelBMFont* label;
	NSString* string;
	
	label = [CCLabelBMFont labelWithString:pack.name fntFile:@"hud-numbers.fnt"];
	label.position = ccp(0, -size.height / 2 + 80);
	[layer addChild:label];
	
	string = [NSString stringWithFormat:@"%d Levels", pack.count];
	label = [CCLabelBMFont labelWithString:string fntFile:@"level-numbers.fnt"];
	label.position = ccp(0, -size.height / 2 + 55);
	[layer addChild:label];
	
	return layer;
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

- (void)onPlay {
	Pack* pack = [[Pack getPacks] objectAtIndex:currentPage];
	CCScene* scene = [LevelSelectionScene sceneWithPack:pack];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	int count = (int)[[Pack getPacks] count];
	
	if (currentPage > 0 && [backButton handleTouchType:type point:point]) {
		[self onBack];
		return;
	}
	if (currentPage < count - 1 && [nextButton handleTouchType:type point:point]) {
		[self onNext];
		return;
	}
	if ([menuButton handleTouchType:type point:point]) {
		[self onMenu];
		return;
	}
	if ([playButton handleTouchType:type point:point]) {
		[self onPlay];
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
