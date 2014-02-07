//
//  Util.m
//  GravityAssist
//
//  Created by Michael Fogleman on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

// Misc
void preloadResources() {
//	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
//	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-image.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-objects.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bodies.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"world.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hud.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"background-window.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"level-background.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu-background.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu-objects.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tutorial-background.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tutorial-grid.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"options-background.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"options-objects.plist"];
//	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"credits-background.plist"];
//	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"coin-hit.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"bumper-hit.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"planet-hit.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"win.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"deploy.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"zip.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"bloop.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"teleport.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"click.mp3"];
}

uint getDeviceModel() {
    struct utsname u;
	uname(&u);
    if (!strcmp(u.machine, "iPhone1,1")) {
		return MODEL_IPHONE;
	}
	else if (!strcmp(u.machine, "iPhone1,2")) {
		return MODEL_IPHONE_3G;
	}
	else if (!strcmp(u.machine, "iPhone2,1")) {
		return MODEL_IPHONE_3GS;
	}
	else if (!strcmp(u.machine, "iPhone3,1")) {
		return MODEL_IPHONE_4;
	}
	else if (!strcmp(u.machine, "iPod1,1")) {
		return MODEL_IPOD_TOUCH_GEN1;
	}
	else if (!strcmp(u.machine, "iPod2,1")) {
		return MODEL_IPOD_TOUCH_GEN2;
	}
	else if (!strcmp(u.machine, "iPod3,1")) {
		return MODEL_IPOD_TOUCH_GEN3;
	}
	else if (!strcmp(u.machine, "iPad1,1")) {
		return MODEL_IPAD;
	}
	else if (!strcmp(u.machine, "i386")) {
		NSString* model = [[UIDevice currentDevice] model];
		if([model compare:@"iPad Simulator"] == NSOrderedSame) {
			return MODEL_IPAD_SIMULATOR;
		}
		else {
			return MODEL_IPHONE_SIMULATOR;
		}
	}
	else {
		return MODEL_UNKNOWN;
	}
}

NSString* getDeviceModelName() {
	switch (getDeviceModel()) {
		case MODEL_IPHONE_SIMULATOR: return @"iPhone Simulator";
		case MODEL_IPAD_SIMULATOR: return @"iPad Simulator";
		case MODEL_IPOD_TOUCH_GEN1: return @"iPod Touch Gen. 1";
		case MODEL_IPOD_TOUCH_GEN2: return @"iPod Touch Gen. 2";
		case MODEL_IPOD_TOUCH_GEN3: return @"iPod Touch Gen. 3";
		case MODEL_IPHONE: return @"iPhone";
		case MODEL_IPHONE_3G: return @"iPhone 3G";
		case MODEL_IPHONE_3GS: return @"iPhone 3GS";
		case MODEL_IPHONE_4: return @"iPhone 4";
		case MODEL_IPAD: return @"iPad";
		default: return @"Unknown Model";
	}
}

BOOL iPadModel() {
	uint model = getDeviceModel();
	return (model == MODEL_IPAD || model == MODEL_IPAD_SIMULATOR);
}

//BOOL isGameCenterAvailable() {
//    Class gcClass = NSClassFromString(@"GKLocalPlayer");
//    NSString* reqSysVer = @"4.1";
//    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
//    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
//    return (gcClass && osVersionSupported);
//}
//
//void authenticateLocalPlayer() {
//    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
//		if (error == nil) {
//			NSLog(@"GK user: %@", [[GKLocalPlayer localPlayer] alias]);
//		}
//		else {
//			NSLog(@"GK error");
//		}
//	}];	
//}

// Geometry
float length(float dx, float dy) {
	return sqrtf(dx * dx + dy * dy);
}

float distance(float x1, float y1, float x2, float y2) {
	return length(x1 - x2, y1 - y2);
}

float spritePointDistance(CCSprite* sprite, CGPoint point) {
	CGPoint pos1 = sprite.position;
	CGPoint pos2 = point;
	return distance(pos1.x, pos1.y, pos2.x, pos2.y);
}

float spriteDistance(CCSprite* a, CCSprite* b) {
	CGPoint pos1 = a.position;
	CGPoint pos2 = b.position;
	return distance(pos1.x, pos1.y, pos2.x, pos2.y);
}

BOOL spriteDistanceWithin(CCSprite* a, CCSprite* b, float maxDistance) {
	CGPoint pos1 = a.position;
	CGPoint pos2 = b.position;
	if (abs(pos1.x - pos2.x) > maxDistance) {
		return NO;
	}
	if (abs(pos1.y - pos2.y) > maxDistance) {
		return NO;
	}
	if (distance(pos1.x, pos1.y, pos2.x, pos2.y) <= maxDistance) {
		return YES;
	}
	return NO;
}

CGPoint circleVectorIntersection(float cx, float cy, float cr, float vx, float vy, float vdx, float vdy) {
	float dx = vx - cx;
	float dy = vy - cy;
	float a = vdx * vdx + vdy * vdy;
	float b = 2 * (vdx * dx + vdy * dy);
	float c = dx * dx + dy * dy - cr * cr;
	float d = b * b - 4 * a * c;
	if (d >= 0) {
		float e = (-b + sqrtf(d)) / (2 * a);
		float x = vx + vdx * e;
		float y = vy + vdy * e;
		return ccp(x, y);
	}
	return ccp(vx, vy); // failed - return original position
}

BOOL isLevelEnabled(int level) {
	for (Pack* pack in [Pack getPacks]) {
		if (level == pack.start) {
			return YES;
		}
	}
	if (getLevelStat(statLevelWinCount, level - 1)) {
		return YES;
	}
	if (getLevelStat(statLevelDieCount, level - 1) >= 3) {
		return YES;
	}
	return NO;
}

int getMostRecentLevel() {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"MostRecentLevel"];
}

int getMostRecentLevelForPack(Pack* pack) {
	NSString* key = [NSString stringWithFormat:@"MostRecentLevel%d", pack.start];
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

void setMostRecentLevel(int level) {
	Pack* pack = getPackForLevel(level);
	NSString* key = [NSString stringWithFormat:@"MostRecentLevel%d", pack.start];
	[[NSUserDefaults standardUserDefaults] setInteger:level forKey:key];
	[[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"MostRecentLevel"];
}


BOOL getSoundDisabled() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundDisabled"];
}

void setSoundDisabled(BOOL value) {
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"SoundDisabled"];
}


BOOL getSwapJoystick() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"SwapJoystick"];
}

void setSwapJoystick(BOOL value) {
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"SwapJoystick"];
}


BOOL getGhostEnabled() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"GhostEnabled"];
}

void setGhostEnabled(BOOL value) {
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"GhostEnabled"];
}

BOOL getAlertShown() {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"AlertShown"];
}

void setAlertShown(BOOL value) {
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:@"AlertShown"];
}

BOOL shouldShowAlert() {
	if (getAlertShown()) {
		return NO;
	}
#ifdef LITE
	if (getLevelStat(statLevelWinCount, 1006)) {
		return YES;
	}
#else
	if (getLevelStat(statLevelWinCount, 40)) {
		return YES;
	}
#endif
	return NO;
}

void resetGame() {
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
}



// Best Metrics
int incrementStat(NSString* key) {
	int value = [[NSUserDefaults standardUserDefaults] integerForKey:key];
	value++;
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
	return value;
}

int getStat(NSString* key) {
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

void removeStat(NSString* key) {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

int incrementLevelStat(NSString* key, int level) {
	key = [NSString stringWithFormat:@"%@%d", key, level];
	return incrementStat(key);
}

int getLevelStat(NSString* key, int level) {
	key = [NSString stringWithFormat:@"%@%d", key, level];
	return getStat(key);
}

void removeLevelStat(NSString* key, int level) {
	key = [NSString stringWithFormat:@"%@%d", key, level];
	removeStat(key);
}

int getBestFuel(int level) {
	NSString* key = [NSString stringWithFormat:@"BestFuel%d", level];
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

void setBestFuel(int level, int fuel) {
	NSString* key = [NSString stringWithFormat:@"BestFuel%d", level];
	[[NSUserDefaults standardUserDefaults] setInteger:fuel forKey:key];
}

int getBestTime(int level) {
	NSString* key = [NSString stringWithFormat:@"BestTime%d", level];
	return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

void setBestTime(int level, int time) {
	NSString* key = [NSString stringWithFormat:@"BestTime%d", level];
	[[NSUserDefaults standardUserDefaults] setInteger:time forKey:key];
}

float getBestDistance(int level) {
	NSString* key = [NSString stringWithFormat:@"BestDistance%d", level];
	return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}

void setBestDistance(int level, float dist) {
	NSString* key = [NSString stringWithFormat:@"BestDistance%d", level];
	[[NSUserDefaults standardUserDefaults] setFloat:dist forKey:key];
}

int getTimeThreshold(int level) {
	switch (level) {
		// Original
		case 1: return 1800;
		case 2: return 4235;
		case 3: return 4967;
		case 4: return 1967;
		case 5: return 1000;
		case 6: return 4650;
		case 7: return 2333;
		case 8: return 5800;
		case 9: return 3417;
		case 10: return 3550;
		case 11: return 5533;
		case 12: return 5883;
		case 13: return 4466;
		case 14: return 3600;
		case 15: return 5433;
		case 16: return 3500;
		case 17: return 7048;
		case 18: return 5300;
		case 19: return 4566;
		case 20: return 5800;
		case 21: return 5083;
		case 22: return 5517;
		case 23: return 6350;
		case 24: return 4333;
		case 25: return 13283;
		case 26: return 9050;
		case 27: return 6700;
		case 28: return 11400;
		case 29: return 8166;
		case 30: return 5649;
		case 31: return 12400;
		case 32: return 16567;
		case 33: return 9617;
		case 34: return 19666;
		case 35: return 10484;
		case 36: return 17841;
		case 37: return 8584;
		case 38: return 8900;
		case 39: return 8816;
		case 40: return 27349;
		case 41: return 22366;
		case 42: return 11367;
		case 43: return 16915;
		case 44: return 5217;
		case 45: return 10483;
		case 46: return 6283;
		case 47: return 19048;
		case 48: return 21550;
		case 49: return 13784;
		case 50: return 9401;
		case 51: return 4831;
		case 52: return 12067;
		case 53: return 8566;
		case 54: return 14267;
		case 55: return 8034;
		case 56: return 25280;
		case 57: return 8950;
		case 58: return 4500;
		case 59: return 14834;
		case 60: return 13485;
		case 61: return 31065;
		case 62: return 14697;
		case 63: return 1500;
		case 64: return 26733;
		case 65: return 5817;
		case 66: return 12432;
		case 67: return 15414;
		case 68: return 20270;
		case 69: return 6750;
		case 70: return 31715;
		case 71: return 8115;
		case 72: return 13817;
		case 73: return 21099;
		case 74: return 24350;
		case 75: return 29565;
		case 76: return 17800;
		case 77: return 4982;
		case 78: return 7433;
		case 79: return 3665;
		case 80: return 6328;
		case 81: return 9717;
		case 82: return 1150;
		case 83: return 50032;
		case 84: return 14612;
		case 85: return 17852;
		
		// Lite
		case 1001: return 7517;
		case 1002: return 16983;
		case 1003: return 28583;
		case 1004: return 11814;
		case 1005: return 14367;
		case 1006: return 15483;
		case 1007: return 31867;
		case 1008: return 25485;
		case 1009: return 33017;
		case 1010: return 22867;
		case 1011: return 9585;
		case 1012: return 28650;
		
		// Bonus
		case 2001: return 22749;
		case 2002: return 5849;
		case 2003: return 5848;
		case 2004: return 7783;
		case 2005: return 8284;
		case 2006: return 6281;
		case 2007: return 9565;
		case 2008: return 23382;
		case 2009: return 15633;
		case 2010: return 5978;
		case 2011: return 13783;
		case 2012: return 70616;
		case 2013: return 29865;
		case 2014: return 28588;
		case 2015: return 8716;
		case 2016: return 21668;
		case 2017: return 29233;
		case 2018: return 20382;
		case 2019: return 49615;
		case 2020: return 27696;
		case 2021: return 11383;
		case 2022: return 20114;
		case 2023: return 16626;
		case 2024: return 18171;
		
		// Undefined
		default: return 0;
	}
}

float getDistanceThreshold(int level) {
	switch (level) {
		default: return 0;
	}
}

int getDistanceStarCount(int level, float value) {
	if (value < kEpsilon) {
		value = getBestDistance(level);
	}
	float threshold = getDistanceThreshold(level);
	if (value < kEpsilon) {
		return 0;
	}
	if (value < threshold) {
		return 3;
	}
	if (value < threshold * 1.5f) {
		return 2;
	}
	return 1;
}

int getTimeStarCount(int level, int value) {
	if (value <= 0) {
		value = getBestTime(level);
	}
	int threshold = getTimeThreshold(level) + 1000;
	if (value <= 0) {
		return 0;
	}
	if (value <= threshold) {
		return 3;
	}
	if (value <= threshold * 2) {
		return 2;
	}
	return 1;
}

int getStarCount(int level, int time, float dist) {
	int a = getTimeStarCount(level, time);
	return a;
//	int b = getDistanceStarCount(level, dist);
//	return (a + b) / 2;
}

Pack* getPackForLevel(int level) {
	for (Pack* pack in [Pack getPacks]) {
		if (level >= pack.start - 1 && level <= pack.end + 1) {
			return pack;
		}
	}
	return nil;
}

id loadLevelData(int number) {
	NSString* name = [NSString stringWithFormat:@"level%d", number];
	NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"star"];
	NSData* json = [NSData dataWithContentsOfFile:path];
	id project = [[CJSONDeserializer deserializer] deserialize:json error:nil];
	id level = [project objectAtIndex:0];
	return level;
}

// Stars
void createStars(int count, CCSpriteBatchNode* batch) {
	CGSize size = [[CCDirector sharedDirector] winSize];
	for (int i = 0; i < count; i++) {
		NSString* name;
		if (i % 15 == 0) {
			int number = arc4random() % 3 + 1;
			name = [NSString stringWithFormat:@"galaxy%d.png", number];
		}
		else {
			int number = arc4random() % 2 + 1;
			name = [NSString stringWithFormat:@"star%d.png", number];
		}
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
		int x = arc4random() % (int)(size.width + kStarPadding * 2) - kStarPadding;
		int y = arc4random() % (int)(size.height + kStarPadding * 2) - kStarPadding;
		sprite.position = ccp(x, y);
		float factor = (float)i / count;
		factor = powf(factor, 2);
		factor = factor * 3 / 4 + 0.25f;
		sprite.scale = factor * kStarScale;
		sprite.opacity = (int)(factor * 255);
		sprite.rotation = arc4random() % 360;
		[batch addChild:sprite];
	}
}

void moveStars(CGPoint offset, CCSpriteBatchNode* batch) {
	float dx = offset.x;
	float dy = offset.y;
	if (dx == 0 && dy == 0) {
		return;
	}
	CGSize size = [[CCDirector sharedDirector] winSize];
	int left = -kStarPadding;
	int right = size.width + kStarPadding;
	int top = size.height + kStarPadding;
	int bottom = -kStarPadding;
	int width = right - left;
	int height = top - bottom;
	for (CCSprite* sprite in batch.children) {
		float multiplier = sprite.scale / kStarScale;
		float x = sprite.position.x + dx * multiplier;
		float y = sprite.position.y + dy * multiplier;
		if (x < left) {
			x = right - (left - (int)x) % width;
		}
		if (x > right) {
			x = left + ((int)x - right) % width;
		}
		if (y < bottom) {
			y = top - (bottom - (int)y) % height;
		}
		if (y > top) {
			y = bottom + ((int)y - top) % height;
		}
		sprite.position = ccp(x, y);
	}
}
