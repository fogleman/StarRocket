//
//  Star.h
//  GravityAssist
//
//  Created by Michael Fogleman on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"
#import "Util.h"

@interface Coin : Entity {
}

#if DO_COPY_TRANSFORM
- (void)copyTransformFromSprite:(CCSprite*)sprite;
- (void)clearTransform;
#endif

@end
