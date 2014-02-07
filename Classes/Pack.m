//
//  Pack.m
//  StarRocket
//
//  Created by Michael Fogleman on 2/23/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import "Pack.h"

@implementation Pack

@synthesize start;
@synthesize end;
@synthesize count;
@synthesize name;

static NSArray* packs = nil;

+ (NSArray*)getPacks {
	@synchronized(self) {
		if (!packs) {
			packs = [Pack createPacks];
		}
	}
	return packs;
}

+ (NSArray*)createPacks {
	NSMutableArray* array = [[NSMutableArray alloc] init];
	
#ifndef LITE
	[array addObject:[[Pack alloc] initWithName:@"Mercury" start:1 end:85]];
	[array addObject:[[Pack alloc] initWithName:@"Venus" start:2001 end:2024]];
#endif
	
	[array addObject:[[Pack alloc] initWithName:@"Pluto" start:1001 end:1012]];
	
	return array;
}

- (id)initWithName:(NSString*)_name start:(int)_start end:(int)_end {
	self = [super init];
	if (self) {
		name = [_name retain];
		start = _start;
		end = _end;
		count = end - start + 1;
	}
	return self;
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end
