//
//  Item.h
//  StarRocket
//
//  Created by Michael Fogleman on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"

#define kItemZipper 0
#define kItemAntenna 1
#define kItemShield 2

@interface Item : Entity {
	int type;
}

@property (nonatomic) int type;

@end
