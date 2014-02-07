//
//  Path.m
//  Performance
//
//  Created by Michael Fogleman on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Path.h"

@implementation Path

- (void)updateEntityWithTimestamp:(int)millisElapsed {
}

@end


@implementation CircularPath

@synthesize entity;
@synthesize x;
@synthesize y;
@synthesize period;
@synthesize clockwise;

- (void)updateEntityWithTimestamp:(int)millisElapsed {
	if (!entity.visible) {
		return;
	}
	if (!cached) {
		// get original position
		float ox = entity.originalPosition.x;
		float oy = entity.originalPosition.y;
		// compute original angle and radius
		float dx = ox - x;
		float dy = oy - y;
		cachedRadius = sqrtf(dx * dx + dy * dy);
		cachedAngle = atan2f(dy, dx);
		if (clockwise) {
			cachedMultiplier = -1;
		}
		else {
			cachedMultiplier = 1;
		}
		cached = YES;
	}
	// compute current angle
	float periods = millisElapsed / (period * 1000);
	float currentAngle = cachedAngle + cachedMultiplier * periods * 2 * kPi;
	// compute current position
	float cx = x + cosf(currentAngle) * cachedRadius;
	float cy = y + sinf(currentAngle) * cachedRadius;
	entity.position = entity.pathPosition = ccp(cx, cy);
}

- (void)dealloc {
	[entity release];
	[super dealloc];
}

@end


@implementation LinearPath

@synthesize entity;
@synthesize x;
@synthesize y;
@synthesize period;

- (void)updateEntityWithTimestamp:(int)millisElapsed {
	if (!entity.visible) {
		return;
	}
	float x1 = entity.originalPosition.x;
	float y1 = entity.originalPosition.y;
	float dx = x - x1;
	float dy = y - y1;
	float x2 = x1 + dx * 2;
	float y2 = y1 + dy * 2;
	float periods = millisElapsed / (period * 1000);
	periods = periods - (int)periods;
	float cx;
	float cy;
	float pct;
	if (periods < 0.5f) {
		pct = periods * 2;
		cx = x1 + (x2 - x1) * pct;
		cy = y1 + (y2 - y1) * pct;
	}
	else {
		pct = (periods - 0.5f) * 2;
		cx = x2 + (x1 - x2) * pct;
		cy = y2 + (y1 - y2) * pct;
	}
	entity.position = ccp(cx, cy);
	entity.pathPosition = ccp(cx, cy);
}

- (void)dealloc {
	[entity release];
	[super dealloc];
}

@end
