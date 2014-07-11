//
//  Host.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "Host.h"

@implementation Host

-(id)initWithDictionary:(NSDictionary *)hostData{
    self = [super init];
    if(self){
        for(NSString * key in hostData){
            if([key isEqualToString:@"host_name"]){
                self.name = [hostData valueForKey:key];
            } else if([key isEqualToString:@"current_state"]){
                self.currentState = [hostData valueForKey:key];
            } else if([key isEqualToString:@"current_attempt"]){
                self.attempt = [hostData valueForKey:key];
            } else if([key isEqualToString:@"last_update"]){
                self.lastUpdated = [hostData valueForKey:key];
            } else if ([key isEqualToString:@"services"]){
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:@"serviceName" forKey:@"name"];
                [dict setObject:@"serviceState" forKey:@"current_state"];
                [dict setObject:@"serviceAttempt" forKey:@"attempt"];
                [dict setObject:@"serviceUpdated" forKey:@"last_updated"];
                self.services = [[NSMutableArray alloc] initWithObjects:dict, nil];
                NSLog(@"Adding %lu services.",[[hostData valueForKey:key] count]);
            }
        }
    }
    return self;
}
@end
