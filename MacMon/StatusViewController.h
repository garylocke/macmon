//
//  StatusViewController.h
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Host.h"
#import "Service.h"

@interface StatusViewController : NSObject <NSOutlineViewDataSource>

+(NSMutableArray *)hosts;
+(void)setHosts:(NSMutableArray *)hostsArray;

@end
