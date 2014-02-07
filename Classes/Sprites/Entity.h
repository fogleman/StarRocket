//
//  Entity.h
//  Performance
//
//  Created by Michael Fogleman on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Entity : CCSprite {
	CGPoint originalPosition;
	CGPoint pathPosition;
}

@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) CGPoint pathPosition;

@end
