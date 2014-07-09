//
//  Host.h
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Host : NSObject

@property (copy) NSString *name;
@property (copy) NSMutableArray *children;
@property (copy) NSString *lastUpdated;

-(id)initWithName:(NSString *)name lastUpdated:(NSString *)lastUpdated;

@end
