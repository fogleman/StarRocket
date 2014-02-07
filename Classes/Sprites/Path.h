//
//  Path.h
//  Performance
//
//  Created by Michael Fogleman on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"
#import "Util.h"

#define kPathCircular 1
#define kPathLinear 2

@interface Path : NSObject {

}

- (void)updateEntityWithTimestamp:(int)millisElapsed;

@end


@interface CircularPath : Path {
	Entity* entity;
	float x;
	float y;
	float period;
	BOOL clockwise;
	
	BOOL cached;
	float cachedRadius;
	float cachedAngle;
	int cachedMultiplier;
}

@property (nonatomic, retain) Entity* entity;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float period;
@property (nonatomic) BOOL clockwise;

- (void)updateEntityWithTimestamp:(int)millisElapsed;

@end


@interface LinearPath : Path {
	Entity* entity;
	float x;
	float y;
	float period;
}

@property (nonatomic, retain) Entity* entity;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float period;

- (void)updateEntityWithTimestamp:(int)millisElapsed;

@end
