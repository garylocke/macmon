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
            if([key isEqualToString:@"host_name"]){
                self.hostName = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"current_state"]){
                self.currentState = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"plugin_ouput"]){
                self.currentStateDetails = [serviceData valueForKey:key];
            }else if([key isEqualToString:@"attempt"]){
                self.attempt = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"last_update"]){
                self.lastUpdated = [serviceData valueForKey:key];
            }
        }
    }
    
    return self;
}

@end