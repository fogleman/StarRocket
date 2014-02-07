//
//  Util.h
//  GravityAssist
//
//  Created by Michael Fogleman on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
//#import "GameKit/GameKit.h"
#import "CJSONDeserializer.h"
#import "Pack.h"
#import <sys/utsname.h>

#define DO_COPY_TRANSFORM 1

#define kTimeDivider 1000
#define kFuelDivider 100
#define kDistanceDivider 10

#define kStateWaiting 1
#define kStatePlaying 2
#define kStateWon 3
#define kStateDied 4
#define kStateCancelled 5
#define kStatePaused 6

#define kStarPadding 64
#define kStarScale 1

#define kEpsilon 1e-9f

#define kBegan 1
#define kMoved 2
#define kEnded 3
#define kCancelled 4

#define statLevelWinCount @"LevelWinCount"
#define statLevelDieCount @"LevelDieCount"
#define statLevelPlayCount @"LevelPlayCount"

#define kPi 3.14159265f
#define RADIANS(degrees) ((degrees) * kPi / 180)
#define DEGREES(radians) ((radians) * 180 / kPi)

enum {
    MODEL_UNKNOWN = 0,
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPAD_SIMULATOR,
    MODEL_IPOD_TOUCH_GEN1,
    MODEL_IPOD_TOUCH_GEN2,
    MODEL_IPOD_TOUCH_GEN3,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPHONE_3GS,
    MODEL_IPHONE_4,
	MODEL_IPAD
};

void preloadResources();
uint getDeviceModel();
NSString* getDeviceModelName();
BOOL iPadModel();

//BOOL isGameCenterAvailable();
//void authenticateLocalPlayer();

BOOL isLevelEnabled(int level);
int getMostRecentLevel();
int getMostRecentLevelForPack(Pack* pack);
void setMostRecentLevel(int level);
BOOL getSoundDisabled();
void setSoundDisabled(BOOL value);
BOOL getSwapJoystick();
void setSwapJoystick(BOOL value);
BOOL getGhostEnabled();
void setGhostEnabled(BOOL value);
BOOL getAlertShown();
void setAlertShown(BOOL value);
BOOL shouldShowAlert();
void resetGame();

float length(float dx, float dy);
float distance(float x1, float y1, float x2, float y2);
float spritePointDistance(CCSprite* sprite, CGPoint point);
float spriteDistance(CCSprite* a, CCSprite* b);
BOOL spriteDistanceWithin(CCSprite* a, CCSprite* b, float distance);
CGPoint circleVectorIntersection(float cx, float cy, float cr, float vx, float vy, float vdx, float vdy);

int incrementStat(NSString* key);
int getStat(NSString* key);
void removeStat(NSString* key);
int incrementLevelStat(NSString* key, int level);
int getLevelStat(NSString* key, int level);
void removeLevelStat(NSString* key, int level);

int getBestFuel(int level);
void setBestFuel(int level, int fuel);
int getBestTime(int level);
void setBestTime(int level, int time);
float getBestDistance(int level);
void setBestDistance(int level, float dist);
int getTimeThreshold(int level);
float getDistanceThreshold(int level);
int getDistanceStarCount(int level, float value);
int getTimeStarCount(int level, int value);
int getStarCount(int level, int time, float dist);

Pack* getPackForLevel(int level);
id loadLevelData(int number);

void createStars(int count, CCSpriteBatchNode* batch);
void moveStars(CGPoint offset, CCSpriteBatchNode* batch);
