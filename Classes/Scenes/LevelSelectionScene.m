//
//  LevelSelectionScene.m
//  StarRocket
//
//  Created by Michael Fogleman on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectionScene.h"

@implementation LevelSelectionScene

+ (CCScene*)sceneWithPack:(Pack*)_pack {
	CCScene* scene = [CCScene node];
	
	LevelSelectionScene* layer = [[[LevelSelectionScene alloc] initWithPack:_pack] autorelease];
	[scene addChild:layer];
	
	return scene;
}

// Initialization
- (id)initWithPack:(Pack*)_pack {
	self = [super init];
	if (self) {
		NSLog(@"LevelSelectionScene init");
		
		pack = _pack;
		selectedLevel = MAX(pack.start, getMostRecentLevelForPack(pack));
		if (selectedLevel < pack.end && 
			getBestTime(selectedLevel) > 0 && 
			getBestTime(selectedLevel + 1) == 0) {
			selectedLevel++;
		}
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"level-background.plist"];
		
		preloadResources();
		
		buttons = [[CCArray alloc] init];
		
		[self createScrollView];
		
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"level-background.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
		
		hudBatch = [CCSpriteBatchNode batchNodeWithFile:@"hud.pvr.ccz"];
		[self addChild:hudBatch];
		[self createSprites];
		
		[self createMenu];
		
		[self onSelect:selectedLevel pan:YES];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

- (void)createBackground {
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"level-background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
}

- (void)createScrollView {
	CCSprite* sprite;
	NSString* string;
	
	scrollLayer = [CCLayer node];
	[self addChild:scrollLayer];
	
	selectionSprite = [CCSprite spriteWithSpriteFrameName:@"level-selection.png"];
	selectionSprite.anchorPoint = ccp(0, 1);
	[scrollLayer addChild:selectionSprite];
	
	scrollBatch = [CCSpriteBatchNode batchNodeWithFile:@"hud.pvr.ccz"];
	[scrollLayer addChild:scrollBatch];
	
	int number = pack.start - 1;
	int count = pack.count;
	int rows = count / 4;
	if (count % 4) {
		rows++;
	}
	int height = rows * 72 + 32;
	for (int y = 0; y < rows; y++) {
		for (int x = 0; x < 4; x++) {
			number++;
			if (number > pack.end) {
				break;
			}
			
			BOOL enabled = isLevelEnabled(number);
			int stars = getStarCount(number, -1, -1);
			CGPoint point = ccp(60 * x + 30, height - 32 - 72 * y);
			
			if (enabled) {
				string = @"button-level-blue.png";
			}
			else {
				string = @"button-level-gray.png";
			}
			float radius = 25;
			Button* button = [Button buttonWithPosition:point radius:radius normalName:string selectedName:string];
			button.tag = number;
			[buttons addObject:button];
			[scrollBatch addChild:button];
			
			if (stars >= 1 && stars <= 3) {
				string = [NSString stringWithFormat:@"level-stars%d.png", stars];
				sprite = [CCSprite spriteWithSpriteFrameName:string];
				sprite.position = point;
				[scrollBatch addChild:sprite];
			}
			
			string = [NSString stringWithFormat:@"%d", number - pack.start + 1];
			point = ccp(point.x, point.y - 32);
			CGSize size = CGSizeMake(10, 13.5f);
			[self addLabelWithString:string center:point size:size batch:scrollBatch];
		}
	}
	
	scrollHeight = height;
	CGPoint center = ccp(220 + 125, 265 - 125);
	CGSize size = CGSizeMake(250, 250);
	CGSize content = CGSizeMake(250, height);
	scrollView = [[ScrollView alloc] initWithCenter:center size:size contentSize:content target:scrollLayer];
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)createSprites {
	CCSprite* sprite;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-level-preview.png"];
	sprite.position = ccp(102, size.height - 30);
	[hudBatch addChild:sprite];
	
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-level-select.png"];
	sprite.position = ccp(338, size.height - 30);
	[hudBatch addChild:sprite];
}

- (void)createThumb:(int)number {
	if (thumbSprite) {
		[self removeChild:thumbSprite cleanup:YES];
	}
	NSString* name = [NSString stringWithFormat:@"thumb%d.png", number];
	thumbSprite = [CCSprite spriteWithFile:name];
	thumbSprite.position = ccp(102, 171);
	if ([[CCDirector sharedDirector] contentScaleFactor] == 1) {
		thumbSprite.scale = 0.5f;
	}
	[self addChild:thumbSprite z:-1];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)createMenu {
	CGPoint point;
	float radius = 32;
	
	point = ccp(42, 39);
	backButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[hudBatch addChild:backButton];
	
	point = ccp(117, 39);
	playButton = [Button buttonWithPosition:point radius:radius normalName:@"button-play.png" selectedName:@"button-play-hi.png"];
	[hudBatch addChild:playButton];
}

- (void)addLabelWithString:(NSString*)string center:(CGPoint)center size:(CGSize)size batch:(CCSpriteBatchNode*)batch {
	int width = size.width * [string length];
	int x = center.x - width / 2 + size.width / 2;
	int y = center.y;
	for (unsigned int i = 0; i < [string length]; i++) {
		unichar c = [string characterAtIndex:i];
		NSString* name = [NSString stringWithFormat:@"%C.png", c];
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
		sprite.position = ccp(x, y);
		[batch addChild:sprite];
		x += size.width;
	}
}

- (void)onBack {
	CCScene* scene = [PackSelectionScene scene];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onPlay {
	CCScene* scene = [GameScene sceneWithLevel:selectedLevel];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onSelect:(int)number pan:(BOOL)pan {
	if (number < pack.start) {
		number = pack.start;
	}
	if (number > pack.end) {
		number = pack.end;
	}
	selectedLevel = number;
	[self createThumb:number];
	int index = number - pack.start;
	int row = index / 4;
	int col = index % 4;
	selectionSprite.position = ccp(col * 60, scrollHeight - row * 72 - 4);
	if (pan) {
		int offset = (row - 1) * 72 + 4;
		offset = MAX(offset, 0);
		offset = MIN(offset, scrollHeight - 250);
		scrollView.contentOffset = ccp(0, offset);
	}
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:nil];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	
	// Buttons
	if ([backButton handleTouchType:type point:point]) {
		[self onBack];
		return;
	}
	if ([playButton handleTouchType:type point:point]) {
		[self onPlay];
		return;
	}
	
	// Level Buttons
	CGRect rect = CGRectMake(220, 15, 250, 250);
	if (type != kEnded || !CGRectContainsPoint(rect, point)) {
		return;
	}
	CGPoint offset = [scrollView contentOffset];
	int x = point.x - 220 - 2;
	int y = point.y - 15 + (scrollHeight - offset.y) - 250 + 2;
	point = ccp(x, y);
	Button* button;
	CCARRAY_FOREACH (buttons, button) {
		if (!isLevelEnabled(button.tag)) {
			continue;
		}
		if ([button handleTouchType:type point:point]) {
			[self onSelect:button.tag pan:NO];
			if (!getSoundDisabled()) {
				[[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3"];
			}
		}
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
	NSLog(@"LevelSelectionScene dealloc");
	[buttons release];
	[scrollView removeFromSuperview];
	[scrollView release];
	[super dealloc];
}

@end
