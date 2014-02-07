//
//  Star.m
//  GravityAssist
//
//  Created by Michael Fogleman on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Coin.h"

@implementation Coin

#if DO_COPY_TRANSFORM
- (void)updateTransform {
	// do nothing
}

- (void)copyTransformFromSprite:(CCSprite*)sprite {
	float x = positionInPixels_.x;
	float y = positionInPixels_.y;
	ccV3F_C4B_T2F_Quad otherQuad = sprite.quad;
	ccVertex3F bl = otherQuad.bl.vertices;
	ccVertex3F br = otherQuad.br.vertices;
	ccVertex3F tl = otherQuad.tl.vertices;
	ccVertex3F tr = otherQuad.tr.vertices;
	quad_.bl.vertices = (ccVertex3F) {
		bl.x + x,
		bl.y + y,
		bl.z
	};
	quad_.br.vertices = (ccVertex3F) {
		br.x + x,
		br.y + y,
		br.z
	};
	quad_.tl.vertices = (ccVertex3F) {
		tl.x + x,
		tl.y + y,
		tl.z
	};
	quad_.tr.vertices = (ccVertex3F) {
		tr.x + x,
		tr.y + y,
		tr.z
	};
	[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	dirty_ = recursiveDirty_ = NO;
}

- (void)clearTransform {
	quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = (ccVertex3F) {0, 0, 0};
	[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	dirty_ = recursiveDirty_ = NO;
}
#endif

@end
