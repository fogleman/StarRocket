//
//  GameScene.h
//  GravityAssist
//
//  Created by Michael Fogleman on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "LevelSelectionScene.h"
#import "SummaryScene.h"
#import "Button.h"
#import "Coin.h"
#import "Bumper.h"
#import "Item.h"
#import "Entity.h"
#import "Teleport.h"
#import "Path.h"
#import "Pack.h"
#import "Util.h"

typedef struct {
	float x;
	float y;
	float rotation;
} GhostRecord;

#define kMaxGhostRecords 6000

@interface GameScene : CCLayer {
	// Batches and Layers
	CCSpriteBatchNode* backgroundBatch;
	CCSpriteBatchNode* starBatch;
	CCSpriteBatchNode* coinBatch;
	CCSpriteBatchNode* bodyBatch;
	CCSpriteBatchNode* worldBatch;
	CCSpriteBatchNode* hudBatch;
	
	// Pause Layer
	CCLayer* pauseLayer;
	Button* pauseMenuButton;
	Button* pausePlayButton;
	Button* pauseRestartButton;
	
	// Entities
	CCArray* planets;
	CCArray* asteroids;
	CCArray* bumpers;
	CCArray* items;
	CCArray* coins;
	CCArray* teleports;
	CCArray* animationCoins;
	CCArray* animationAsteroids;
	CCArray* animationCrash;
	CCArray* paths;
	
	// Rocket
	CCSprite* rocketSprite;
	CCSprite* pointerSprite;
	CCSprite* shieldSprite;
	CCSprite* antennaSprite;
	CCSprite* antennaWavesSprite;
	BOOL thrust;
	int shieldTimeout;
	int antennaTimeout;
	BOOL teleportFlag;
	CGPoint velocity;
	
	// Ghost
	CCSprite* ghostSprite;
	unsigned int currentGhostIndex;
	unsigned int savedGhostCount;
	GhostRecord savedGhost[kMaxGhostRecords];
	GhostRecord currentGhost[kMaxGhostRecords];
	
	// Other
	int state;
	int stateBeforePause;
	int level;
	NSString* levelName;
	int sceneMillisElapsed;
	float timeError;
	BOOL playSounds;
	BOOL showGhost;
	BOOL replayGhost;
	CCSprite* sharedBumperSprite;
	CCSprite* sharedCoinSprite;
	Pack* pack;
	
	// Metrics
	int fuelUsed;
	int millisElapsed;
	float distanceTraveled;
	int totalCoins;
	int coinsCollected;
	int bestFuel;
	int bestTime;
	float bestDistance;
	
	// HUD
	CCLabelBMFont* coinLabel;
	CCLabelBMFont* timeLabel;
	CCSprite* endLabel;
	int prevCoin;
	int prevTime;
//	BOOL timeExceeded;
//	BOOL distanceExceeded;
	Button* restartButton;
	Button* pauseButton;
	CGPoint joystick;
	CGPoint button;
	CCSprite* dpadSprite;
	CCSprite* joystickSprite;
	CCSprite* buttonSprite;
	CCSprite* indicatorStars;
	CCSprite* indicatorTime;
	NSUInteger joystickHash;
	NSUInteger buttonHash;
	NSUInteger summaryHash;
}

@property (nonatomic) int level;
@property (nonatomic) int state;
@property (nonatomic) int fuelUsed;
@property (nonatomic) int millisElapsed;
@property (nonatomic) float distanceTraveled;

+ (CCScene*)sceneWithLevel:(int)_level;

- (id)initWithLevel:(int)_level;

- (void)createPauseLayer;
- (void)createPauseWindow;
- (void)createPauseMenu;
- (void)createPauseText;

- (void)createBackground;
- (void)createSharedActionSprites;
- (void)updateSharedActions;
- (void)createRocket;

- (id)createPlanetWithPosition:(CGPoint)_position scale:(float)_scale sprite:(int)_sprite;
- (id)createAsteroidWithPosition:(CGPoint)_position scale:(float)_scale;
- (id)createItemWithPosition:(CGPoint)_position type:(int)type;
- (id)createTeleportWithPosition:(CGPoint)_position number:(int)number target:(int)target;
- (id)createBumperWithPosition:(CGPoint)_position scale:(float)_scale;
- (id)createCoinWithPosition:(CGPoint)_position;

- (void)createHud;
- (void)updateHud;

- (void)onRestart;
- (void)onPause;
- (void)onPlay;
- (void)onMenu;

- (void)setJoystick:(BOOL)active;
- (void)setThrust:(BOOL)_thrust;
- (void)setShield:(BOOL)shield;
- (void)setAntenna:(BOOL)antenna;

- (void)tick;
- (void)panWithOffset:(CGPoint)offset;

- (void)doPaths;
- (void)doCoins;
- (void)doPlanetCollisions;
- (void)doAsteroidCollisions;
- (void)doItemCollisions;
- (void)doTeleportCollisions;
- (void)teleportTo:(int)number;
- (void)doBumperCollisions;

- (void)end;
- (void)saveData;
- (void)win;
- (void)die;

- (void)showEndMessage:(NSString*)message;

- (void)createCoinHitSprites;
- (void)createAsteroidHitSprites;
- (void)createCrashSprites;
- (void)createHitAnimationAtPosition:(CGPoint)point sprites:(CCArray*)sprites;
- (void)doStarTrail;

- (void)doGhost;
- (void)loadGhost;
- (void)saveGhost;

- (void)loadPathForEntity:(Entity*)entity data:(id)data;
- (void)loadLevel;

@end
