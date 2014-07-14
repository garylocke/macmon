//
//  Services.m
//  MacMon
//
//  Created by dbader on 7/9/14.
//  Copyright (c) 2014 dbader. All rights reserved.
//

#import "Service.h"

@implementation Service

-(id)initWithDictionary:(NSDictionary *)serviceData{
    self = [super init];
    
    if(self){
        for(NSString *key in serviceData){
            if([key isEqualToString:@"service_description"]){
                self.name = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"current_state"]){
                self.currentState = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"plugin_output"]){
                self.pluginOutput = [serviceData valueForKey:key];
            }else if([key isEqualToString:@"current_attempt"]){
                self.currentAttempt = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"last_update"]){
                self.lastUpdate = [serviceData valueForKey:key];
            }
        }
    }
    
    return self;
}

@end