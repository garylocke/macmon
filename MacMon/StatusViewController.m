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

// Initalize View Controller (should not happen until hosts/services arrays are populated).
-(id)init{
    self = [super init];
    if(self){}
    return self;
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

/*
 * Methods called as the data source for the NSOutlineView.
 */
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    NSInteger retval = !item ? [hosts count] : [[item children] count];
    NSLog(@"outlineView:numberOfChildrenOfItem runs, returning %lu",retval);
    return retval;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    BOOL retval = !item ? NO : [[item children] count] != 0;
    NSLog(@"outlineView:isItemExpandable runs, returning %d",retval);
    return retval;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    id retval = !item ? [hosts objectAtIndex:index] : [[item children] objectAtIndex:index];
    NSLog(@"outlineView:child:ofItem runs, returning %@",retval);
    return retval;
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    NSLog(@"outlineView:objectValueForTableColumn:byItem runs for item:");
    NSLog(@"%@",item);
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
