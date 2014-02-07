//
//  GameScene.m
//  GravityAssist
//
//  Created by Michael Fogleman on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"

#define DO_BACKGROUND 1
#define DO_ACTIONS 1
#define DO_COIN_SHIFTS 1
#define DO_POINTER 1
#define DO_ANIMATIONS 1
#define DO_PATHS 1
#define DO_HUD 1
#define DO_SOUNDS 1

#define DO_REPLAY 0

#define kBackgroundStars 100
#define kAnimationSprites 4
#define kCoinHitSprites 100
#define kAsteroidHitSprites 20
#define kCrashSprites 5

#define kTicksPerSecond 1000
#define kStutter 0.2f

//#define kGravity 4e-4f
//#define kThrust 2e-4f
//#define kGlide 5e-5f
//#define kFriction 5e-4f

#define kGravity 6e-4f
#define kThrust 3e-4f
#define kGlide 6e-5f
#define kFriction 6e-4f

//#define kGravity 6e-4f
//#define kThrust 3e-4f
//#define kGlide 6e-5f
//#define kFriction 5e-4f

#define kDefaultPull 4e4f
#define kAntennaPull 4e5f
#define kAsteroidDrag 0.75f
#define kZipperMultiplier 800

#define kRocketRadius 20
#define kCoinRadius 12
#define kPlanetRadius 64
#define kBumperRadius 64
#define kAsteroidRadius 24
#define kItemRadius 16
#define kTeleportRadius 20

#define kCoinOffset -2
#define kPlanetOffset 4
#define kBumperOffset 2
#define kAsteroidOffset 4
#define kItemOffset 0
#define kTeleportOffset 2

#define kGhostRate 10
#define kShieldDuration 8000
#define kAntennaDuration 8000

#define kHudOpacity 128

#define zCoins 1
#define zPlanets 2
#define zAnimations 3
#define zRocket 4

@implementation GameScene

// Properties
@synthesize level;
@synthesize state;
@synthesize fuelUsed;
@synthesize millisElapsed;
@synthesize distanceTraveled;

// Scene
+ (CCScene*)sceneWithLevel:(int)_level {
	CCScene* scene = [CCScene node];
	
	GameScene* layer = [[[GameScene alloc] initWithLevel:_level] autorelease];
	[scene addChild:layer];
	
	return scene;
}

// Initialization
- (id)initWithLevel:(int)_level {
	self = [super init];
	if (self) {
		level = _level;
		pack = getPackForLevel(level);
		if (level < pack.start || level > pack.end) {
			level = pack.start;
		}
		state = kStateWaiting;
		NSLog(@"Starting level %d", level);
		setMostRecentLevel(level);
		
		bestFuel = getBestFuel(level);
		bestTime = getBestTime(level);
		bestDistance = getBestDistance(level);
		playSounds = !getSoundDisabled();
		showGhost = getGhostEnabled();
		
		replayGhost = DO_REPLAY;
		
		planets = [[CCArray alloc] init];
		asteroids = [[CCArray alloc] init];
		bumpers = [[CCArray alloc] init];
		items = [[CCArray alloc] init];
		coins = [[CCArray alloc] init];
		teleports = [[CCArray alloc] init];
		paths = [[CCArray alloc] init];
		
		animationCoins = [[CCArray alloc] init];
		animationAsteroids = [[CCArray alloc] init];
		animationCrash = [[CCArray alloc] init];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-image.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-objects.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bodies.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"world.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-window.plist"];
		
		preloadResources();
		
		// Background Image
#if DO_BACKGROUND
		backgroundBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-image.pvr.ccz"];
		[self addChild:backgroundBatch];
		[self createBackground];
#endif
		
		// Background Stars
		starBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-objects.pvr.ccz"];
		[self addChild:starBatch];
		createStars(kBackgroundStars, starBatch);
		
		// World
		coinBatch = [CCSpriteBatchNode batchNodeWithFile:@"world.pvr.ccz"];
		[self addChild:coinBatch];
		
		bodyBatch = [CCSpriteBatchNode batchNodeWithFile:@"bodies.pvr.ccz"];
		[self addChild:bodyBatch];
		
		worldBatch = [CCSpriteBatchNode batchNodeWithFile:@"world.pvr.ccz"];
		[self addChild:worldBatch];
		
		[self createSharedActionSprites];
		[self createCoinHitSprites];
		[self createAsteroidHitSprites];
		[self createCrashSprites];
		[self createRocket];
		[self loadLevel];
		[self loadGhost];
		[self panWithOffset:ccp(0, 0)];
		
		// HUD
		hudBatch = [CCSpriteBatchNode batchNodeWithFile:@"hud.pvr.ccz"];
		[self addChild:hudBatch];
		
		[self createHud];
		[self updateHud];
		
#if !DO_HUD
		hudBatch.visible = NO;
#endif
		
		// Pause Layer
		[self createPauseLayer];
		
		self.isTouchEnabled = YES;
		[self scheduleUpdate];
	}
	return self;
}



// Pause Layer
- (void)createPauseLayer {
	pauseLayer = [CCLayer node];
	pauseLayer.visible = NO;
	[self createPauseWindow];
	[self createPauseMenu];
	[self createPauseText];
	[self addChild:pauseLayer];
}

- (void)createPauseWindow {
	CCSpriteBatchNode* pauseBatch = [CCSpriteBatchNode batchNodeWithFile:@"background-window.pvr.ccz"];
	[pauseLayer addChild:pauseBatch];
	
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"background-window.png"];
	sprite.anchorPoint = ccp(0, 0);
	[pauseBatch addChild:sprite];
}

- (void)createPauseMenu {
	CGPoint point;
	int offset = 39;
	float radius = 32;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	point = ccp(size.width - offset, size.height - offset);
	pausePlayButton = [Button buttonWithPosition:point radius:radius normalName:@"button-play.png" selectedName:@"button-play-hi.png"];
	[pauseLayer addChild:pausePlayButton];
	
	point = ccp(size.width - offset, offset - 2);
	pauseRestartButton = [Button buttonWithPosition:point radius:radius normalName:@"button-restart.png" selectedName:@"button-restart-hi.png"];
	[pauseLayer addChild:pauseRestartButton];
	
	point = ccp(offset, size.height - offset);
	pauseMenuButton = [Button buttonWithPosition:point radius:radius normalName:@"button-menu.png" selectedName:@"button-menu-hi.png"];
	[pauseLayer addChild:pauseMenuButton];
}

- (void)createPauseText {
	NSString* string;
	CCSprite* sprite;
	CCLabelBMFont* label;
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// Paused
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-paused.png"];
	sprite.position = ccp(size.width / 2, size.height - 80);
	[pauseLayer addChild:sprite];
	
	// Level
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-level.png"];
	sprite.position = ccp(size.width / 2, size.height - 125);
	[pauseLayer addChild:sprite];
	
	string = [NSString stringWithFormat:@"%d", level - pack.start + 1];
	label = [CCLabelBMFont labelWithString:string fntFile:@"hud-numbers.fnt"];
	label.position = ccp(size.width / 2, size.height - 160);
	label.opacity = 192;
	[pauseLayer addChild:label];
	
	// Best Time
	sprite = [CCSprite spriteWithSpriteFrameName:@"text-best.png"];
	sprite.position = ccp(size.width / 2, size.height - 190);
	[pauseLayer addChild:sprite];
	
	if (bestTime > 0) {
		string = [NSString stringWithFormat:@"%.2f", (float)bestTime / kTimeDivider];
	}
	else {
		string = @"n/a";
	}
	label = [CCLabelBMFont labelWithString:string fntFile:@"hud-numbers.fnt"];
	label.position = ccp(size.width / 2, size.height - 225);
	label.opacity = 192;
	[pauseLayer addChild:label];
	
	int count = getTimeStarCount(level, -1);
	if (count >= 1 && count <= 3) {
		string = [NSString stringWithFormat:@"stars%d.png", count];
		sprite = [CCSprite spriteWithSpriteFrameName:string];
		sprite.position = ccp(size.width / 2, size.height - 250);
		[pauseLayer addChild:sprite];
	}
}



// Sound Helpers
- (void)playSound:(NSString*)name {
#if DO_SOUNDS
	if (playSounds) {
		[[SimpleAudioEngine sharedEngine] playEffect:name];
	}
#endif
}

// Object Creation
- (void)createBackground {
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"background.png"];
	sprite.anchorPoint = ccp(0, 0);
	[backgroundBatch addChild:sprite];
}

- (void)createSharedActionSprites {
	sharedCoinSprite = [CCSprite spriteWithSpriteFrameName:@"coin.png"];
	sharedCoinSprite.opacity = 0;
	[coinBatch addChild:sharedCoinSprite];
	
	id action1 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:-360] rate:2];
	id action2 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:360] rate:2];
	id action3 = [CCSequence actions:action1, action2, nil];
	id action4 = [CCRepeat actionWithAction:action3 times:5];
	id action5 = [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:2 angle:-180*5] rate:2];
	id action6 = [CCSequence actions:action4, action5, action2, nil];
	id action7 = [CCRepeatForever actionWithAction:action6];
	[sharedCoinSprite runAction:action7];
	
	sharedBumperSprite = [CCSprite spriteWithSpriteFrameName:@"coin-hit.png"]; // just a small sprite
	sharedBumperSprite.visible = NO;
	[self addChild:sharedBumperSprite];
	
	id action8 = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:1.05f] rate:2];
	id action9 = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25f scale:0.95f] rate:2];
	id action10 = [CCSequence actions:action8, action9, nil];
	id action11 = [CCRepeatForever actionWithAction:action10];
	[sharedBumperSprite runAction:action11];
}

- (void)updateSharedActions {
#if DO_ACTIONS
	float s = sharedBumperSprite.scale;
	Bumper* bumper;
	CCARRAY_FOREACH (bumpers, bumper) {
		bumper.scale = bumper.originalScale * s;
	}
#endif
}

- (void)createRocket {
	velocity = ccp(0, 0);
	// Ghost
	ghostSprite = [CCSprite spriteWithSpriteFrameName:@"rocket.png"];
	ghostSprite.opacity = 128;
	ghostSprite.rotation = -90;
	if (!showGhost) {
		ghostSprite.visible = NO;
	}
	[worldBatch addChild:ghostSprite z:zRocket];
	// Rocket
	rocketSprite = [CCSprite spriteWithSpriteFrameName:@"rocket.png"];
	rocketSprite.rotation = -90;
	[worldBatch addChild:rocketSprite z:zRocket];
	// Shield
	shieldSprite = [CCSprite spriteWithSpriteFrameName:@"shield.png"];
	shieldSprite.visible = NO;
	shieldSprite.position = ccp(32, 32);
	[rocketSprite addChild:shieldSprite];
	// Antenna
	antennaSprite = [CCSprite spriteWithSpriteFrameName:@"antenna.png"];
	antennaSprite.position = ccp(25, 32);
	[rocketSprite addChild:antennaSprite z:-1];
	// Antenna Waves
	antennaWavesSprite = [CCSprite spriteWithSpriteFrameName:@"antenna-waves.png"];
	antennaWavesSprite.position = ccp(60, 32);
	antennaWavesSprite.visible = NO;
	[rocketSprite addChild:antennaWavesSprite];
#if DO_ACTIONS
	id action1 = [CCFadeOut actionWithDuration:0.5f];
	id action2 = [CCFadeTo actionWithDuration:0 opacity:255];
	id action3 = [CCSequence actions:action1, action2, nil];
	id action4 = [CCRepeatForever actionWithAction:action3];
	[antennaWavesSprite runAction:action4];
#endif
	// Pointer
	pointerSprite = [CCSprite spriteWithSpriteFrameName:@"pointer.png"];
	pointerSprite.opacity = 0;
	[worldBatch addChild:pointerSprite z:zRocket];
}

- (id)createPlanetWithPosition:(CGPoint)_position scale:(float)_scale sprite:(int)_sprite {
	NSString* names[] = {
		@"planet1.png",
		@"planet2.png",
		@"planet3.png",
		@"planet4.png",
		@"planet5.png",
		@"planet6.png",
		@"planet7.png",
	};
	int count = 7;
	Entity* sprite = [Entity spriteWithSpriteFrameName:names[_sprite % count]];
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	sprite.position = _position;
	sprite.scale = _scale;
	[bodyBatch addChild:sprite z:zPlanets];
	[planets addObject:sprite];
	return sprite;
}

- (id)createAsteroidWithPosition:(CGPoint)_position scale:(float)_scale {
	NSString* names[] = {
		@"asteroid1.png",
		@"asteroid2.png",
	};
	int count = 2;
	int index = arc4random() % count;
	Entity* sprite = [Entity spriteWithSpriteFrameName:names[index]];
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	sprite.position = _position;
	sprite.scale = _scale;
	sprite.rotation = arc4random() % 360;
	[bodyBatch addChild:sprite z:zPlanets];
	[asteroids addObject:sprite];
	// action
#if DO_ACTIONS
	int speed = arc4random() % 10 + 5;
	int mult = arc4random() % 2;
	if (!mult) {
		mult = -1;
	}
	id action1 = [CCRotateBy actionWithDuration:speed angle:mult * 360];
	id action2 = [CCRepeatForever actionWithAction:action1];
	[sprite runAction:action2];
#endif
	return sprite;
}

- (id)createItemWithPosition:(CGPoint)_position type:(int)type {
	NSString* name;
	switch (type) {
		case kItemAntenna:
			name = @"item-antenna.png";
			break;
		case kItemShield:
			name = @"item-shield.png";
			break;
		case kItemZipper:
			name = @"item-zipper.png";
			break;
		default:
			return nil;
	}
	Item* sprite = [Item spriteWithSpriteFrameName:name];
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	sprite.type = type;
	sprite.position = _position;
	[worldBatch addChild:sprite z:zCoins];
	[items addObject:sprite];
	return sprite;
}

- (id)createTeleportWithPosition:(CGPoint)_position number:(int)number target:(int)target {
	Teleport* sprite = [Teleport spriteWithSpriteFrameName:@"teleport.png"];
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	sprite.number = number;
	sprite.target = target;
	sprite.position = _position;
	[worldBatch addChild:sprite z:zCoins];
	[teleports addObject:sprite];
	// action
#if DO_ACTIONS
	id action1 = [CCRotateBy actionWithDuration:2 angle:360];
	id action2 = [CCRepeatForever actionWithAction:action1];
	[sprite runAction:action2];
#endif
	return sprite;
}

- (id)createBumperWithPosition:(CGPoint)_position scale:(float)_scale {
	Bumper* sprite = [Bumper spriteWithSpriteFrameName:@"bumper.png"];
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	sprite.position = _position;
	sprite.scale = _scale;
	sprite.originalScale = _scale;
	[bodyBatch addChild:sprite z:zPlanets];
	[bumpers addObject:sprite];
	return sprite;
}

- (id)createCoinWithPosition:(CGPoint)_position {
	Coin* sprite = [Coin spriteWithSpriteFrameName:@"coin.png"];
	sprite.position = _position;
	sprite.originalPosition = _position;
	sprite.pathPosition = _position;
	[coinBatch addChild:sprite z:zCoins];
	[coins addObject:sprite];
	totalCoins++;
	return sprite;
}



// HUD
- (void)createHud {
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// Controls
	if (getSwapJoystick()) {
		joystick = ccp(size.width - 80, 80);
		button = ccp(70, 60);
	}
	else {
		joystick = ccp(80, 80);
		button = ccp(size.width - 70, 60);
	}
	
	dpadSprite = [CCSprite spriteWithSpriteFrameName:@"dpad.png"];
	dpadSprite.position = joystick;
	dpadSprite.opacity = kHudOpacity;
	[hudBatch addChild:dpadSprite];
	
	joystickSprite = [CCSprite spriteWithSpriteFrameName:@"joystick.png"];
	joystickSprite.position = joystick;
	joystickSprite.opacity = kHudOpacity;
	[hudBatch addChild:joystickSprite];
	
	buttonSprite = [CCSprite spriteWithSpriteFrameName:@"button-thrust.png"];
	buttonSprite.position = button;
	buttonSprite.opacity = kHudOpacity;
	[hudBatch addChild:buttonSprite];
	
	// End Message
	endLabel = [CCSprite spriteWithSpriteFrameName:@"text-touch-to-continue.png"];
	endLabel.position = ccp(size.width / 2, size.height / 2);
	endLabel.visible = NO;
	[hudBatch addChild:endLabel];
	
	// Menu
	CGPoint point;
	float radius = 24;
	int s = 45;
	int p = 10;
	
	point = ccp(size.width - p - s / 2 - p - s, size.height - p - s / 2);
	restartButton = [Button buttonWithPosition:point radius:radius normalName:@"hud-restart.png" selectedName:@"hud-restart-hi.png"];
	restartButton.opacity = kHudOpacity;
	restartButton.normalOpacity = kHudOpacity;
	restartButton.selectedOpacity = kHudOpacity;
	[hudBatch addChild:restartButton];
	
	point = ccp(size.width - p - s / 2, size.height - p - s / 2);
	pauseButton = [Button buttonWithPosition:point radius:radius normalName:@"hud-pause.png" selectedName:@"hud-pause-hi.png"];
	pauseButton.opacity = kHudOpacity;
	pauseButton.normalOpacity = kHudOpacity;
	pauseButton.selectedOpacity = kHudOpacity;
	[hudBatch addChild:pauseButton];
	
	// Indicators
	indicatorStars = [CCSprite spriteWithSpriteFrameName:@"indicator-stars-blue.png"];
	indicatorStars.position = ccp(p, size.height - p);
	indicatorStars.anchorPoint = ccp(0, 1);
	indicatorStars.opacity = kHudOpacity;
	[hudBatch addChild:indicatorStars];
	
	indicatorTime = [CCSprite spriteWithSpriteFrameName:@"indicator-time-blue.png"];
	indicatorTime.position = ccp(90 + p * 2, size.height - p);
	indicatorTime.anchorPoint = ccp(0, 1);
	indicatorTime.opacity = kHudOpacity;
	[hudBatch addChild:indicatorTime];
	
	coinLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"hud-numbers.fnt"];
	coinLabel.position = ccp(p + 60, size.height - p - 28);
	coinLabel.opacity = 192;
	[self addChild:coinLabel];
	
	timeLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"hud-numbers.fnt"];
	timeLabel.position = ccp(90 + p * 2 + 60, size.height - p - 28);
	timeLabel.opacity = 192;
	[self addChild:timeLabel];
}

- (void)updateHud {
	NSString* string;
	int value;
	
	value = totalCoins - coinsCollected;
	if (value != prevCoin) {
		prevCoin = value;
		string = [NSString stringWithFormat:@"%d", value];
		[coinLabel setString:string];
	}
	
	value = millisElapsed / kTimeDivider;
	if (value != prevTime) {
		prevTime = value;
		string = [NSString stringWithFormat:@"%d", value];
		[timeLabel setString:string];
	}
}

- (void)onRestart {
	state = kStateCancelled;
	CCScene* scene = [GameScene sceneWithLevel:level];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void)onPause {
	stateBeforePause = state;
	state = kStatePaused;
	pauseLayer.visible = YES;
	coinBatch.visible = NO;
	bodyBatch.visible = NO;
	worldBatch.visible = NO;
	hudBatch.visible = NO;
}

- (void)onPlay {
	state = stateBeforePause;
	pauseLayer.visible = NO;
	coinBatch.visible = YES;
	bodyBatch.visible = YES;
	worldBatch.visible = YES;
	hudBatch.visible = YES;
}

- (void)onMenu {
	CCScene* scene = [LevelSelectionScene sceneWithPack:pack];
	scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
	[[CCDirector sharedDirector] replaceScene:scene];
}



- (void)setJoystick:(BOOL)active {
	NSString* name;
	if (active) {
		name = @"dpad-hi.png";
	}
	else {
		name = @"dpad.png";
	}
	CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
	[dpadSprite setDisplayFrame:frame];
}

- (void)setThrust:(BOOL)_thrust {
	if (thrust != _thrust) {
		thrust = _thrust;
		NSString* name;
		if (thrust) {
			name = @"button-thrust-hi.png";
		}
		else {
			name = @"button-thrust.png";
		}
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
		[buttonSprite setDisplayFrame:frame];
	}
}

- (void)setShield:(BOOL)shield {
	[self playSound:@"deploy.mp3"];
	if (shield) {
		shieldSprite.scale = 0;
		shieldSprite.visible = YES;
		id action1 = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:1] period:0.3f];
		[shieldSprite stopAllActions];
		[shieldSprite runAction:action1];
	}
	else {
		id action1 = [CCEaseElasticIn actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:0] period:0.3f];
		id action2 = [CCHide action];
		id action3 = [CCSequence actions:action1, action2, nil];
		[shieldSprite stopAllActions];
		[shieldSprite runAction:action3];
	}
}

- (void)setAntenna:(BOOL)antenna {
	[self playSound:@"deploy.mp3"];
	if (antenna) {
		id action1 = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(32, 32)] rate:2];
		[antennaSprite runAction:action1];
		antennaWavesSprite.visible = YES;
	}
	else {
		id action1 = [CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(25, 32)] rate:2];
		[antennaSprite runAction:action1];
		antennaWavesSprite.visible = NO;
	}
}



// Timer Handling
- (void)update:(ccTime)dt {
	if (state == kStatePaused) {
		return;
	}
	
	if (dt > kStutter) {
		dt = 1 / 60.0f;
	}
	
	CGPoint before = rocketSprite.position;
	
	// run ticks
	int ticks = (int)(dt * kTicksPerSecond);
	timeError += dt * kTicksPerSecond - ticks;
	int extra = (int)timeError;
	timeError -= extra;
	ticks += extra;
	for (int i = 0; i < ticks; i++) {
		[self tick];
	}
	
	if (shieldTimeout > 0 && millisElapsed > shieldTimeout) {
		shieldTimeout = 0;
		[self setShield:NO];
	}
	
	if (antennaTimeout > 0 && millisElapsed > antennaTimeout) {
		antennaTimeout = 0;
		[self setAntenna:NO];
	}
	
	// collisions
	[self updateSharedActions];
	[self doPaths];
	[self doBumperCollisions];
	[self doPlanetCollisions];
	[self doAsteroidCollisions];
	[self doItemCollisions];
	[self doTeleportCollisions];
	[self doCoins];
	
	// panning
	CGPoint after = rocketSprite.position;
	CGPoint offset = ccp(before.x - after.x, before.y - after.y);
	[self panWithOffset:offset];
	
	// hud
	[self updateHud];
}

- (void)tick {
	sceneMillisElapsed++;
	
	if (state != kStatePlaying) {
		return;
	}
	
	millisElapsed++;
	
	int rate = 400;
	if (thrust) {
		rate = 150;
	}
	if (millisElapsed % rate == 0) {
		[self doStarTrail];
	}
	
	if (millisElapsed % kGhostRate == 0) {
		[self doGhost];
	}
	
	// update velocity
	float x = rocketSprite.position.x;
	float y = rocketSprite.position.y;
	float vx = velocity.x;
	float vy = velocity.y;
	// ...via thrust
	float multiplier = kGlide;
	if (thrust) {
		fuelUsed++;
		multiplier = kThrust;
	}
	float angle = -RADIANS(rocketSprite.rotation);
	vx += cosf(angle) * multiplier;
	vy += sinf(angle) * multiplier;
	// ...via gravity
	CCSprite* planet;
	CCARRAY_FOREACH (planets, planet) {
		float dx = planet.position.x - x;
		float dy = planet.position.y - y;
		float dist2 = dx * dx + dy * dy;
		float dist = sqrtf(dist2);
		float mass = powf(planet.scale * kPlanetRadius, 2);
		float magnitude = kGravity * mass / dist2;
		float ux = dx / dist;
		float uy = dy / dist;
		vx += ux * magnitude;
		vy += uy * magnitude;
	}
	// ...via friction
	vx *= (1 - kFriction);
	vy *= (1 - kFriction);
	// finalize it
	float v = length(vx, vy);
	distanceTraveled += v;
	velocity = ccp(vx, vy);
	
	// update position
	x += vx;
	y += vy;
	rocketSprite.position = ccp(x, y);
}

- (void)panWithOffset:(CGPoint)offset {
	CGSize size = [[CCDirector sharedDirector] winSize];
	float x = size.width / 2 - rocketSprite.position.x;
	float y = size.height / 2 - rocketSprite.position.y;
	CGPoint point = ccp(x, y);
	coinBatch.position = point;
	bodyBatch.position = point;
	worldBatch.position = point;
	moveStars(offset, starBatch);
}



// Collision Detection
- (void)doPaths {
#if DO_PATHS
	Path* path;
	CCARRAY_FOREACH (paths, path) {
		[path updateEntityWithTimestamp:sceneMillisElapsed];
	}
#endif
}

- (void)doCoins {
	// *** Pre-Iteration ***
	CCArray* coinsToRemove = nil;
	float rx = rocketSprite.position.x;
	float ry = rocketSprite.position.y;
	
#if DO_ACTIONS && !DO_COPY_TRANSFORM
	float sharedRotation = sharedCoinSprite.rotation;
#endif
	
#if DO_POINTER
	Coin* nearestCoin = nil;
	float nearestDist = 1e9f;
#endif
	
#if DO_COIN_SHIFTS
	float pull = kDefaultPull;
	if (antennaSprite.visible) {
		float pct = (antennaSprite.position.x - 25) / 7.0f;
		pull = kDefaultPull + pct * (kAntennaPull - kDefaultPull);
	}
#endif
	
	// *** Iteration ***
	Coin* coin;
	CCARRAY_FOREACH (coins, coin) {
		float sx = coin.pathPosition.x;
		float sy = coin.pathPosition.y;
		float dx = rx - sx;
		float dy = ry - sy;
		float dist2 = dx * dx + dy * dy;
		float dist = sqrtf(dist2);
		
#if DO_COIN_SHIFTS
		float magnitude = MIN(dist, pull / dist2);
		float ux = dx / dist;
		float uy = dy / dist;
		float x = sx + ux * magnitude;
		float y = sy + uy * magnitude;
		dist -= magnitude;
		coin.position = ccp(x, y);
#endif
		
#if DO_POINTER
		if (dist < nearestDist) {
			nearestDist = dist;
			nearestCoin = coin;
		}
#endif
		
#if DO_ACTIONS
#if DO_COPY_TRANSFORM
		[coin copyTransformFromSprite:sharedCoinSprite];
#else
		coin.rotation = sharedRotation;
#endif
#endif
		
		if (state == kStatePlaying && dist <= kRocketRadius + kCoinRadius + kCoinOffset) {
			// State
			coinsCollected++;
			coin.visible = NO;
#if DO_COPY_TRANSFORM
			[coin clearTransform];
#endif
			if (coinsToRemove == nil) {
				coinsToRemove = [[CCArray alloc] init];
			}
			[coinsToRemove addObject:coin];
			// Sound
			[self playSound:@"coin-hit.wav"];
			// Explosion
			[self createHitAnimationAtPosition:coin.position sprites:animationCoins];
			// Indicator
#if DO_ACTIONS
			[indicatorStars stopAllActions];
			indicatorStars.opacity = 255;
			id action1 = [CCFadeTo actionWithDuration:0.5f opacity:kHudOpacity];
			id action2 = [CCEaseOut actionWithAction:action1 rate:2];
			[indicatorStars runAction:action2];
#endif
			// Win
			if (coinsCollected == totalCoins) {
				[self playSound:@"win.mp3"];
				[self win];
			}
		}
	}
	
	// *** Post-Iteration ***
	if (coinsToRemove != nil) {
		CCARRAY_FOREACH (coinsToRemove, coin) {
			[coins fastRemoveObject:coin];
		}
		[coinsToRemove release];
	}
	
#if DO_POINTER
	if (state == kStatePlaying && nearestCoin) {
		if (nearestDist > 240) {
			if (pointerSprite.opacity != 255 && [pointerSprite numberOfRunningActions] == 0) {
				id action = [CCFadeIn actionWithDuration:0.5f];
				[pointerSprite runAction:action];
			}
		}
		else {
			if (pointerSprite.opacity != 0 && [pointerSprite numberOfRunningActions] == 0) {
				id action = [CCFadeOut actionWithDuration:0.5f];
				[pointerSprite runAction:action];
			}
		}
		if (pointerSprite.opacity > 0) {
			float dx = nearestCoin.position.x - rx;
			float dy = nearestCoin.position.y - ry;
			float radians = atan2f(dy, dx);
			float degrees = DEGREES(radians);
			float x = rx + cosf(radians) * 70;
			float y = ry + sinf(radians) * 70;
			pointerSprite.position = ccp(x, y);
			pointerSprite.rotation = -degrees;
		}
	}
	else {
		pointerSprite.opacity = 0;
	}
#endif
}

- (void)doPlanetCollisions {
	if (state != kStatePlaying) {
		return;
	}
	CCSprite* planet;
	CCARRAY_FOREACH (planets, planet) {
		float distance = planet.scale * kPlanetRadius + kRocketRadius - kPlanetOffset;
		if (spriteDistanceWithin(planet, rocketSprite, distance)) {
			[self playSound:@"planet-hit.wav"];
			[self die];
			break;
		}
	}
}

- (void)doAsteroidCollisions {
	if (state != kStatePlaying) {
		return;
	}
	CCSprite* asteroid;
	CCARRAY_FOREACH (asteroids, asteroid) {
		if (!asteroid.visible) {
			continue;
		}
		float distance = asteroid.scale * kAsteroidRadius + kRocketRadius;
		if (shieldSprite.visible) {
			if (spriteDistanceWithin(asteroid, rocketSprite, distance + kAsteroidOffset)) {
				asteroid.visible = NO;
				velocity = ccp(velocity.x * kAsteroidDrag, velocity.y * kAsteroidDrag);
				[self createHitAnimationAtPosition:asteroid.position sprites:animationAsteroids];
				[self playSound:@"planet-hit.wav"];
				break;
			}
		}
		else {
			if (spriteDistanceWithin(asteroid, rocketSprite, distance - kAsteroidOffset)) {
				[self die];
				[self playSound:@"planet-hit.wav"];
				break;
			}
		}
	}
}

- (void)doItemCollisions {
	if (state != kStatePlaying) {
		return;
	}
	Item* item;
	CCARRAY_FOREACH (items, item) {
		if (!item.visible) {
			continue;
		}
		if ([item numberOfRunningActions] > 0) {
			continue;
		}
		float distance = kItemRadius + kRocketRadius - kItemOffset;
		if (spriteDistanceWithin(item, rocketSprite, distance)) {
			if (item.type == kItemZipper) {
				float vx = velocity.x;
				float vy = velocity.y;
				float angle = -RADIANS(rocketSprite.rotation);
				float multiplier = kThrust * kZipperMultiplier;
				vx += cosf(angle) * multiplier;
				vy += sinf(angle) * multiplier;
				velocity = ccp(vx, vy);
				[self playSound:@"zip.mp3"];
			}
			else if (item.type == kItemShield) {
				[self setShield:YES];
				shieldTimeout = millisElapsed + kShieldDuration;
			}
			else if (item.type == kItemAntenna) {
				[self setAntenna:YES];
				antennaTimeout = millisElapsed + kAntennaDuration;
			}
#if DO_ACTIONS
			float duration = 0.4f;
			id action1 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:duration scale:4] rate:2];
			id action2 = [CCEaseOut actionWithAction:[CCFadeOut actionWithDuration:duration] rate:2];
			id action3 = [CCSpawn actions:action1, action2, nil];
			id action4 = [CCHide action];
			id action5 = [CCSequence actions:action3, action4, nil];
			[item runAction:action5];
#else
			item.visible = NO;
#endif
		}
	}
}

- (void)doTeleportCollisions {
	if (state != kStatePlaying) {
		return;
	}
	BOOL collision = NO;
	Teleport* teleport;
	CCARRAY_FOREACH (teleports, teleport) {
		float distance = kTeleportRadius + kRocketRadius - kTeleportOffset;
		if (spriteDistanceWithin(teleport, rocketSprite, distance)) {
			collision = YES;
			if (!teleportFlag) {
				[self teleportTo:teleport.target];
				break;
			}
		}
	}
	teleportFlag = collision;
}

- (void)teleportTo:(int)number {
	Teleport* teleport;
	CCARRAY_FOREACH (teleports, teleport) {
		if (teleport.number == number) {
			rocketSprite.position = teleport.position;
			[self playSound:@"teleport.mp3"];
			break;
		}
	}
}

- (void)doBumperCollisions {
	if (state != kStatePlaying) {
		return;
	}
	Bumper* bumper;
	CCARRAY_FOREACH (bumpers, bumper) {
		float distance = bumper.originalScale * kBumperRadius + kRocketRadius - kBumperOffset;
		if (spriteDistanceWithin(bumper, rocketSprite, distance)) {
			CGPoint point = circleVectorIntersection(bumper.position.x, bumper.position.y, distance + 1, rocketSprite.position.x, rocketSprite.position.y, -velocity.x, -velocity.y);
			rocketSprite.position = point;
			CGPoint collision = ccpSub(bumper.position, rocketSprite.position);
			float d = length(collision.x, collision.y);
			collision = ccp(collision.x / d, collision.y / d);
			float mul = -ccpDot(velocity, collision) * 2; // TODO: add energy?
			velocity = ccp(velocity.x + collision.x * mul, velocity.y + collision.y * mul);
			[self playSound:@"bumper-hit.mp3"];
//#if DO_ACTIONS
//			CCAnimation* animation = [CCAnimation animation];
//			animation.delay = 5 / 60.0f;
//			[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bumper-hi.png"]];
//			[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bumper.png"]];
//			id action = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO];
//			[bumper stopAllActions];
//			[bumper runAction:action];
//#endif
			break;
		}
	}
}

- (void)end {
	[self setThrust:NO];
	[self setJoystick:NO];
	rocketSprite.visible = NO;
	joystickSprite.position = joystick;
	[self createHitAnimationAtPosition:rocketSprite.position sprites:animationCrash];
}

- (void)win {
	incrementLevelStat(statLevelWinCount, level);
	state = kStateWon;
	[self end];
//	if (bestTime > 0 && millisElapsed < bestTime) {
//	}
//	if (bestDistance > kEpsilon && distanceTraveled < bestDistance) {
//	}
	[self showEndMessage:@"text-complete.png"];
}

- (void)die {
	incrementLevelStat(statLevelDieCount, level);
	state = kStateDied;
	[self end];
	[self showEndMessage:@"text-failed.png"];
}

- (void)showEndMessage:(NSString*)name {
	CGSize size = [[CCDirector sharedDirector] winSize];
	// message
	CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
	sprite.position = ccp(size.width / 2, size.height / 2);
	sprite.scale = 0;
	id action1 = [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.5f scale:1] period:0.3f];
	id action2 = [CCEaseIn actionWithAction:[CCFadeOut actionWithDuration:1] rate:2];
	id action3 = [CCSequence actions:action1, action2, nil];
	[sprite runAction:action3];
	[hudBatch addChild:sprite];
	// continue
	endLabel.opacity = 0;
	endLabel.visible = YES;
	id action4 = [CCActionInterval actionWithDuration:1.5f];
	id action5 = [CCEaseInOut actionWithAction:[CCFadeIn actionWithDuration:1] rate:2];
	id action6 = [CCSequence actions:action4, action5, nil];
	[endLabel runAction:action6];
}



// Animations
- (void)createCoinHitSprites {
#if DO_ANIMATIONS
	for (int i = 0; i < kCoinHitSprites; i++) {
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"coin-hit.png"];
		sprite.visible = NO;
		[worldBatch addChild:sprite z:zAnimations];
		[animationCoins addObject:sprite];
	}
#endif
}

- (void)createAsteroidHitSprites {
#if DO_ANIMATIONS
	for (int i = 0; i < kAsteroidHitSprites; i++) {
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"asteroid1.png"];
		sprite.scale = 0.25f;
		sprite.visible = NO;
		[bodyBatch addChild:sprite z:zAnimations];
		[animationAsteroids addObject:sprite];
	}
#endif
}

- (void)createCrashSprites {
#if DO_ANIMATIONS
	for (int i = 0; i < kCrashSprites; i++) {
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"smoke.png"];
		sprite.visible = NO;
		sprite.scale = 2;
		[worldBatch addChild:sprite z:zAnimations];
		[animationCrash addObject:sprite];
	}
#endif
}

- (void)createHitAnimationAtPosition:(CGPoint)point sprites:(CCArray*)sprites {
#if DO_ANIMATIONS
	int count = kAnimationSprites;
	CCSprite* sprite;
	CCARRAY_FOREACH (sprites, sprite) {
		if (!count) {
			break;
		}
		if (sprite.visible) {
			continue;
		}
		count--;
		sprite.visible = YES;
		sprite.position = point;
		sprite.rotation = arc4random() % 360;
		float duration = 1;
		int dx = arc4random() % 150 - 75;
		int dy = arc4random() % 150 - 75;
		int da = arc4random() % 720 - 360;
		id action1 = [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:duration position:ccp(dx, dy)] rate:2];
		id action2 = [CCEaseOut actionWithAction:[CCFadeOut actionWithDuration:duration] rate:2];
		id action3 = [CCEaseOut actionWithAction:[CCRotateBy actionWithDuration:duration angle:da] rate:2];
		id action4 = [CCSpawn actions:action1, action2, action3, nil];
		id action5 = [CCHide action];
		id action6 = [CCSequence actions:action4, action5, nil];
		[sprite runAction:action6];
	}
#endif
}

- (void)doStarTrail {
	[self playSound:@"bloop.wav"];
#if DO_ANIMATIONS
	CCSprite* sprite;
	CCARRAY_FOREACH (animationCoins, sprite) {
		if (sprite.visible) {
			continue;
		}
		int d;
		float rx = rocketSprite.position.x;
		float ry = rocketSprite.position.y;
		float radians = RADIANS(180 - rocketSprite.rotation);
		sprite.visible = YES;
		sprite.scale = 0.8f;
		d = 25;
		sprite.position = ccp(rx + cosf(radians) * d, ry + sinf(radians) * d);
		sprite.rotation = arc4random() % 360;
		int da = arc4random() % 720 - 360;
		float duration = 2;
		d = 120;
		CGPoint p = ccp(rx + cosf(radians) * d, ry + sinf(radians) * d);
		id action1 = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:duration position:p] rate:2];
		id action2 = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:duration scale:2] rate:2];
		id action3 = [CCEaseOut actionWithAction:[CCFadeOut actionWithDuration:duration] rate:2];
		id action4 = [CCEaseOut actionWithAction:[CCRotateBy actionWithDuration:duration angle:da] rate:2];
		id action5 = [CCSpawn actions:action1, action2, action3, action4, nil];
		id action6 = [CCHide action];
		id action7 = [CCScaleTo actionWithDuration:0 scale:1];
		id action8 = [CCSequence actions:action5, action6, action7, nil];
		[sprite runAction:action8];
		break;
	}
#endif
}



// Ghost
- (void)doGhost {
	GhostRecord record;
	// restore saved record
	if (currentGhostIndex < savedGhostCount) {
		record = savedGhost[currentGhostIndex];
		if (replayGhost) {
			rocketSprite.position = ccp(record.x, record.y);
			rocketSprite.rotation = record.rotation;
			float radians = RADIANS(-record.rotation);
			joystickSprite.position = ccp(joystick.x + cosf(radians) * 25, joystick.y + sinf(radians) * 25);
		}
		else if (showGhost) {
			ghostSprite.position = ccp(record.x, record.y);
			ghostSprite.rotation = record.rotation;
		}
	}
	// save current record
	if (currentGhostIndex < kMaxGhostRecords) {
		record.x = rocketSprite.position.x;
		record.y = rocketSprite.position.y;
		record.rotation = rocketSprite.rotation;
		currentGhost[currentGhostIndex] = record;
		currentGhostIndex++;
	}
}

- (void)loadGhost {
	NSString* key = [NSString stringWithFormat:@"Ghost%d", level];
#if DO_REPLAY
	NSString* filePath = [[NSBundle mainBundle] pathForResource:key ofType:@""];
	NSData* data = [NSData dataWithContentsOfFile:filePath];
#else
	NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
#endif
	if (data) {
		unsigned int length = MIN([data length], sizeof(GhostRecord) * kMaxGhostRecords);
		[data getBytes:savedGhost length:length];
		savedGhostCount = length / sizeof(GhostRecord);
		if (savedGhostCount > 0) {
			GhostRecord record = savedGhost[0];
			ghostSprite.position = ccp(record.x, record.y);
			ghostSprite.rotation = record.rotation;
		}
	}
	else {
		savedGhostCount = 0;
		ghostSprite.visible = NO;
	}
}

- (void)saveGhost {
	NSString* key = [NSString stringWithFormat:@"Ghost%d", level];
	unsigned int length = sizeof(GhostRecord) * currentGhostIndex;
	NSData* data = [NSData dataWithBytes:currentGhost length:length];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

- (void)saveData {
	if (state == kStateWon) {
		if (bestFuel == 0 || fuelUsed < bestFuel) {
			bestFuel = fuelUsed;
			setBestFuel(level, bestFuel);
		}
		if (bestTime == 0 || millisElapsed < bestTime) {
			bestTime = millisElapsed;
			setBestTime(level, bestTime);
			[self saveGhost];
		}
		if (bestDistance < kEpsilon || distanceTraveled < bestDistance) {
			bestDistance = distanceTraveled;
			setBestDistance(level, bestDistance);
		}
	}
}



// Touch Handling
- (void)handleJoystickTouch:(CGPoint)point {
	float dx = point.x - joystick.x;
	float dy = point.y - joystick.y;
	float radians = atan2f(dy, dx);
	float dist = length(dx, dy);
	dist = MIN(dist, 25);
	joystickSprite.position = ccp(joystick.x + cosf(radians) * dist, joystick.y + sinf(radians) * dist);
	if (dist > 5) {
		int angle = -(int)(DEGREES(radians));
		rocketSprite.rotation = angle;
	}
}

- (void)handleTouch:(UITouch*)touch type:(int)type {
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:location];
	NSUInteger hash = [touch hash];
	int controlDistance = 140;
	
	// Buttons
	if (state == kStatePaused) {
		if ([pauseMenuButton handleTouchType:type point:point]) {
			[self onMenu];
			return;
		}
		if ([pausePlayButton handleTouchType:type point:point]) {
			[self onPlay];
			return;
		}
		if ([pauseRestartButton handleTouchType:type point:point]) {
			[self onRestart];
			return;
		}
		return; // always return if paused
	}
	
	// Summary Scene
	if (state == kStateWon || state == kStateDied) {
		if (type == kBegan) {
			summaryHash = hash;
		}
		else if (type == kEnded) {
			if (hash == summaryHash) {
				[self saveData];
				CCScene* scene = [SummaryScene sceneWithGameScene:self];
				scene = [CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)];
				[[CCDirector sharedDirector] replaceScene:scene];
			}
		}
		else if (type == kCancelled) {
			if (hash == summaryHash) {
				summaryHash = 0;
			}
		}
		return;
	}
	
	// Buttons
	if ([pauseButton handleTouchType:type point:point]) {
		[self onPause];
		return;
	}
	if ([restartButton handleTouchType:type point:point]) {
		[self onRestart];
		return;
	}
	
	// Normal Method
	if (type == kBegan) {
		if (spritePointDistance(joystickSprite, point) < controlDistance) {
			joystickHash = hash;
			[self handleJoystickTouch:point];
			[self setJoystick:YES];
		}
		else if (spritePointDistance(buttonSprite, point) < controlDistance) {
			buttonHash = hash;
			if (state == kStateWaiting) {
				state = kStatePlaying;
				incrementLevelStat(statLevelPlayCount, level);
			}
			[self setThrust:YES];
		}
	}
	else if (type == kMoved) {
		if (hash == buttonHash) {
			// do nothing
		}
		else if (hash == joystickHash) {
			[self handleJoystickTouch:point];
		}
		else if (spritePointDistance(joystickSprite, point) < controlDistance) {
			// not claimed by any hash?
			joystickHash = hash;
			[self handleJoystickTouch:point];
		}
	}
	else if (type == kEnded || type == kCancelled) {
		if (hash == joystickHash) {
			[self setJoystick:NO];
			joystickSprite.position = joystick;
			joystickHash = 0;
		}
		else if (hash == buttonHash) {
			[self setThrust:NO];
			buttonHash = 0;
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



// Level Creation
- (void)loadPathForEntity:(Entity*)entity data:(id)data {
	if (!entity) {
		return;
	}
	id mapping = [data objectForKey:@"path"];
	if (!mapping) {
		return;
	}
	int type = [[mapping objectForKey:@"type"] intValue];
	if (type == kPathCircular) {
		float x = [[mapping objectForKey:@"x"] floatValue];
		float y = [[mapping objectForKey:@"y"] floatValue];
		float period = [[mapping objectForKey:@"period"] floatValue];
		BOOL clockwise = [[mapping objectForKey:@"clockwise"] boolValue];
		CircularPath* path = [[CircularPath alloc] init];
		path.entity = entity;
		path.x = x;
		path.y = y;
		path.period = period;
		path.clockwise = clockwise;
		[paths addObject:path];
	}
	else if (type == kPathLinear) {
		float x = [[mapping objectForKey:@"x"] floatValue];
		float y = [[mapping objectForKey:@"y"] floatValue];
		float period = [[mapping objectForKey:@"period"] floatValue];
		LinearPath* path = [[LinearPath alloc] init];
		path.entity = entity;
		path.x = x;
		path.y = y;
		path.period = period;
		[paths addObject:path];
	}
}

- (void)loadLevel {
	id levelData = loadLevelData(level);
	levelName = [levelData objectForKey:@"name"];
	id mapping = [levelData objectForKey:@"entities"];
	id entities;
	id entity;
	
	entities = [mapping objectForKey:@"asteroids"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		float _scale = [[data objectForKey:@"scale"] floatValue];
		entity = [self createAsteroidWithPosition:ccp(x, y) scale:_scale];
		[self loadPathForEntity:entity data:data];
	}
	
	entities = [mapping objectForKey:@"bumpers"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		float _scale = [[data objectForKey:@"scale"] floatValue];
		entity = [self createBumperWithPosition:ccp(x, y) scale:_scale];
		[self loadPathForEntity:entity data:data];
	}
	
	entities = [mapping objectForKey:@"items"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		int type = [[data objectForKey:@"type"] intValue];
		entity = [self createItemWithPosition:ccp(x, y) type:type];
		[self loadPathForEntity:entity data:data];
	}
	
	entities = [mapping objectForKey:@"planets"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		float _scale = [[data objectForKey:@"scale"] floatValue];
		int _sprite = [[data objectForKey:@"sprite"] intValue];
		entity = [self createPlanetWithPosition:ccp(x, y) scale:_scale sprite:_sprite];
		[self loadPathForEntity:entity data:data];
	}
	
	entities = [mapping objectForKey:@"rockets"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		rocketSprite.position = ccp(x, y);
	}
	
	entities = [mapping objectForKey:@"stars"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		entity = [self createCoinWithPosition:ccp(x, y)];
		[self loadPathForEntity:entity data:data];
	}
	
	entities = [mapping objectForKey:@"teleports"];
	for (id data in entities) {
		int x = [[data objectForKey:@"x"] intValue];
		int y = [[data objectForKey:@"y"] intValue];
		int number = [[data objectForKey:@"number"] intValue];
		int target = [[data objectForKey:@"target"] intValue];
		entity = [self createTeleportWithPosition:ccp(x, y) number:number target:target];
		[self loadPathForEntity:entity data:data];
	}
}

// Cleanup
- (void)dealloc {
	NSLog(@"GameScene dealloc");
	[asteroids release];
	[planets release];
	[bumpers release];
	[items release];
	[coins release];
	[teleports release];
	[paths release];
	[animationCoins release];
	[animationAsteroids release];
	[animationCrash release];
	[super dealloc];
}

@end
