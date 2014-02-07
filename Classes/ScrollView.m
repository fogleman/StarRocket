//
//  ScrollView.m
//  StarRocket
//
//  Created by Michael Fogleman on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView

@synthesize target;

- (id)initWithCenter:(CGPoint)_center size:(CGSize)_size contentSize:(CGSize)_content target:(CCNode*)_target {
	self = [super initWithFrame:CGRectZero];
	if (self) {
		NSLog(@"ScrollView init");
		ccCenter = _center;
		self.target = _target;
		self.bounds = CGRectMake(0, 0, _size.width, _size.height);
		self.contentSize = _content;
		self.delegate = self;
		[self setUserInteractionEnabled:YES];
		[self setScrollEnabled:YES];
		[[[CCDirector sharedDirector] openGLView] addSubview:self];
		// initial setup
		[self doRotation];
		[self doPosition];
		// orientation changes
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(orientationChanged:) 
													 name:UIDeviceOrientationDidChangeNotification 
												   object:nil];
	}
	return self;
}

- (void)orientationChanged:(NSNotification*)notification {
	[self doRotation];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	[self doPosition];
}

- (void)doRotation {
	CCDirector* director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	if (director.deviceOrientation == kCCDeviceOrientationLandscapeLeft) {
		self.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90));
		self.center = ccp(ccCenter.y, ccCenter.x);
	}
	else {
		self.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90));
		self.center = ccp(size.height - ccCenter.y, size.width - ccCenter.x);
	}
}

- (void)doPosition {
	CGPoint offset = [self contentOffset];
	CGSize size = self.bounds.size;
	CGPoint point = ccp(ccCenter.x - size.width / 2, ccCenter.y - size.height / 2);
	target.position = ccp(point.x - offset.x, point.y - self.contentSize.height + size.height + offset.y);
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if (!self.dragging) {
//		[self.nextResponder touchesBegan:touches withEvent:event];
		[[[CCDirector sharedDirector] openGLView] touchesBegan:touches withEvent:event];
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	if (!self.dragging) {
//		[self.nextResponder touchesEnded:touches withEvent:event];
		[[[CCDirector sharedDirector] openGLView] touchesEnded:touches withEvent:event];
	}
	[super touchesEnded:touches withEvent:event];
}

- (void)dealloc {
	NSLog(@"ScrollView dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[target release];
	[super dealloc];
}

@end
