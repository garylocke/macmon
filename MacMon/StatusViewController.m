//
//  StatusViewController.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "StatusViewController.h"

@implementation StatusViewController

-(id)init{
    self = [super init];
    if(self){
        
        // Array to store hosts.
        _hosts = [[NSMutableArray alloc] init];
        
        // Example host.
        Host *host1 = [[Host alloc] initWithName:@"host_name1" status_value:@"GOOD" attempt:@"1" lastUpdated:@"12345"];
        
        // Example dictionary of checks to add to host.
        NSMutableArray *services = [NSMutableArray arrayWithObjects:
                             [[Host alloc] initWithName:@"service1" status_value:@"GOOD" attempt:@"3" lastUpdated:@"673546"],
                             [[Host alloc] initWithName:@"service2" status_value:@"OHGODWHY" attempt:@"2" lastUpdated:@"123353545"],
                             nil];
        
        // Adding checks array to host.
        [host1 setChildren:services];
        
        // Add example host to hosts array.
        [_hosts addObject:host1];
    }
    return self;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return !item ? [self.hosts count] : [[item children] count];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return !item ? NO : [[item children] count] != 0;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    return !item ? [self.hosts objectAtIndex:index] : [[item children] objectAtIndex:index];
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if([[tableColumn identifier] isEqualToString:@"host_name"])
        return [item name];
    else if([[tableColumn identifier] isEqualToString:@"status_value"])
        return [item status_value];
    else if([[tableColumn identifier] isEqualToString:@"attempt"])
        return [item attempt];
    else if([[tableColumn identifier] isEqualToString:@"last_updated"])
        return [item lastUpdated];
    return @"Toasty!";
}

@end
