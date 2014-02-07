//
//  Button.h
//  StarRocket
//
//  Created by Michael Fogleman on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Util.h"

@interface Button : CCSprite {
	CGRect rect;
	NSString* normalName;
	NSString* selectedName;
	GLubyte normalOpacity;
	GLubyte selectedOpacity;
	BOOL selected;
}

@property (nonatomic) CGRect rect;
@property (nonatomic, retain) NSString* normalName;
@property (nonatomic, retain) NSString* selectedName;
@property (nonatomic) GLubyte normalOpacity;
@property (nonatomic) GLubyte selectedOpacity;

+ (Button*)buttonWithPosition:(CGPoint)point_ 
					   radius:(float)radius_ 
				   normalName:(NSString*)normalName_ 
				 selectedName:(NSString*)selectedName_;

- (void)setFrame;
- (void)setFrame:(NSString*)name;
- (void)setSelected:(BOOL)selected_;
- (BOOL)handleTouchType:(int)type point:(CGPoint)point;

@end
