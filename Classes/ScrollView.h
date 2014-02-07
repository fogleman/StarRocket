//
//  ScrollView.h
//  StarRocket
//
//  Created by Michael Fogleman on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface ScrollView : UIScrollView <UIScrollViewDelegate> {
	CGPoint ccCenter;
	CCNode* target;
}

@property (nonatomic, retain) CCNode* target;

- (id)initWithCenter:(CGPoint)_center size:(CGSize)_size contentSize:(CGSize)_content target:(CCNode*)_target;
- (void)orientationChanged:(NSNotification*)notification;
- (void)doRotation;
- (void)doPosition;

@end
