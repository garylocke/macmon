//
//  Host.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "Host.h"
#import "Service.h"

@implementation Host

-(id)initWithDictionary:(NSDictionary *)hostData{
    self = [super init];
    if(self){
        
        //NSLog(@"%@",hostData);
        
        // Array to store hosts services.
        self.services = [[NSMutableArray alloc] init];
        
        // For each key in the host data dictionary, store values from the real Nagios keys in the appropriate Host object properties.
        for(NSString * key in hostData){
            
            if([key isEqualToString:@"host_name"])
                self.name = [hostData valueForKey:key];
            
            else if([key isEqualToString:@"current_state"])
                self.currentState = [hostData valueForKey:key];
            
            else if([key isEqualToString:@"current_attempt"])
                self.currentAttempt = [hostData valueForKey:key];
            
            else if([key isEqualToString:@"last_update"])
                self.lastUpdate = [hostData valueForKey:key];
            
            else if([key isEqualToString:@"services"]){

                NSLog(@"Adding %lu services.",[[hostData valueForKey:key] count]);
                
                for(NSDictionary *service in [hostData valueForKey:key]){
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[service valueForKey:@"service_description"] forKey:@"service_description"];
                    [dict setObject:[service valueForKey:@"current_state"] forKey:@"current_state"];
                    [dict setObject:[service valueForKey:@"current_attempt"] forKey:@"current_attempt"];
                    [dict setObject:[service valueForKey:@"last_update"] forKey:@"last_update"];
                    Service *service = [[Service alloc] initWithDictionary:dict];
                    NSLog(@"Adding service: %@",service);
                    
                    [self.services addObject:service];
                }
            }
        }
    }
    return self;
}
@end
