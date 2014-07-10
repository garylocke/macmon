//
//  StatusViewController.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "StatusViewController.h"

@implementation StatusViewController

static NSMutableArray *hosts;
static NSMutableArray *services;

// Initalize View Controller (should not happen until hosts/services arrays are populated).
-(id)init{
    self = [super init];
    if(self){}
    return self;
}

/*
 * Set children for Hosts by matching hostnames from each service.
 */
-(void)setHostChildrenFromServices{
    for(Host *host in hosts){
        NSMutableArray *children;
        for(NSDictionary *service in services){
            for(NSString *key in service){
                if([service[key] isEqualToString:@"host_name"]){
                    if([[service valueForKey:key] isEqualToString:[host valueForKey:@"host_name"]]){
                        [children addObject:service];
                    }
                }
            }
        }
        [host setChildren:children];
    }
}

/*
 * Static methods to set hosts and services arrays.
 */
+(NSMutableArray *)hosts{
    return hosts;
}
+(void)setHosts:(NSArray *)hostsArray{
    hosts = [hostsArray copy];
}
+(NSMutableArray *)services{
    return services;
}
+(void)setServices:(NSArray *)servicesArray{
    services = [servicesArray copy];
}

/*
 * Methods called as the data source for the NSOutlineView.
 */
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return !item ? [hosts count] : [[item children] count];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return !item ? NO : [[item children] count] != 0;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    return !item ? [hosts objectAtIndex:index] : [[item children] objectAtIndex:index];
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if([[tableColumn identifier] isEqualToString:@"host_name"])
        return [item name];
    else if([[tableColumn identifier] isEqualToString:@"current_state"])
        return [item currentState];
    else if([[tableColumn identifier] isEqualToString:@"attempt"])
        return [item attempt];
    else if([[tableColumn identifier] isEqualToString:@"last_updated"])
        return [item lastUpdated];
    return @"Toasty!";
}

@end
