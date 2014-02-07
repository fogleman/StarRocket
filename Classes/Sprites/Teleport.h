//
//  Teleport.h
//  StarRocket
//
//  Created by Michael Fogleman on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"

@interface Teleport : Entity {
	int number;
	int target;
}

@property (nonatomic) int number;
@property (nonatomic) int target;

@end
