//
//  Host.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "Host.h"

@implementation Host

-(id)initWithName:(NSString *)name lastUpdated:(NSString *)lastUpdated {
    self = [super init];
    if(self){
        _name = [name copy];
        _children = [[NSMutableArray alloc] init];
        _lastUpdated = [lastUpdated copy];
    }
    return self;
}
@end
