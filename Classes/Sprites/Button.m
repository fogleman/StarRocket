//
//  Button.m
//  StarRocket
//
//  Created by Michael Fogleman on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Button.h"

@implementation Button

@synthesize rect;
@synthesize normalName;
@synthesize selectedName;
@synthesize normalOpacity;
@synthesize selectedOpacity;

+ (Button*)buttonWithPosition:(CGPoint)point_ 
					   radius:(float)radius_ 
				   normalName:(NSString*)normalName_ 
				 selectedName:(NSString*)selectedName_ 
{
	Button* button = [[[Button alloc] initWithSpriteFrameName:normalName_] autorelease];
	button.position = point_;
	button.rect = CGRectMake(point_.x - radius_, point_.y - radius_, radius_ * 2, radius_ * 2);
	button.normalName = normalName_;
	button.selectedName = selectedName_;
	button.normalOpacity = 255;
	button.selectedOpacity = 255;
	return button;
}

- (void)setFrame {
	[self setFrame:normalName];
	self.opacity = normalOpacity;
}

- (void)setFrame:(NSString*)name {
	CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
	[self setDisplayFrame:frame];
}

- (void)setSelected:(BOOL)selected_ {
	if (selected_ != selected) {
		if (!getSoundDisabled()) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3"];
		}
		selected = selected_;
		if (selected) {
			[self setFrame:selectedName];
			self.opacity = selectedOpacity;
		}
		else {
			[self setFrame:normalName];
			self.opacity = normalOpacity;
		}
	}
}

- (BOOL)handleTouchType:(int)type point:(CGPoint)point {
	BOOL result = NO;
	BOOL inside = CGRectContainsPoint(rect, point);
	if (type == kBegan) {
		[self setSelected:inside];
	}
	else if (type == kMoved) {
		[self setSelected:inside];
	}
	else if (type == kEnded) {
		if (inside) {
			result = YES;
		}
		[self setSelected:NO];
	}
	else if (type == kCancelled) {
		[self setSelected:NO];
	}
	return result;
}

- (void)dealloc {
	[normalName release];
	[selectedName release];
	[super dealloc];
}

@end
