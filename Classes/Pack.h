//
//  Pack.h
//  StarRocket
//
//  Created by Michael Fogleman on 2/23/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pack : NSObject {
	int start;
	int end;
	int count;
	NSString* name;
}

@property (nonatomic) int start;
@property (nonatomic) int end;
@property (nonatomic) int count;
@property (nonatomic, retain) NSString* name;

+ (NSArray*)getPacks;
+ (NSArray*)createPacks;

- (id)initWithName:(NSString*)_name start:(int)_start end:(int)_end;

@end
