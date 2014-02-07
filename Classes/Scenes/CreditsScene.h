//
//  CreditsScene.h
//  StarRocket
//
//  Created by Michael Fogleman on 1/26/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Button.h"
#import "OptionsScene.h"
#import "Util.h"

@interface CreditsScene : CCLayer {
	CCSpriteBatchNode* backgroundBatch;
	CCSpriteBatchNode* starBatch;
	Button* menuButton;
}

+ (CCScene*)scene;

- (void)createBackground;
- (void)createWindow;
- (void)createMenu;

@end
