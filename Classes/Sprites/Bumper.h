//
//  Bumper.h
//  GravityAssist
//
//  Created by Michael Fogleman on 11/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"

@interface Bumper : Entity {
	float originalScale;
}

@property (nonatomic) float originalScale;

@end
