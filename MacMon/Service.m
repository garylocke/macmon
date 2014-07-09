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
                _hostName = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"current_state"]){
                _currentState = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"plugin_ouput"]){
                _currentStateDetails = [serviceData valueForKey:key];
            }else if([key isEqualToString:@"attempt"]){
                _attempt = [serviceData valueForKey:key];
            } else if([key isEqualToString:@"last_update"]){
                _lastUpdated = [serviceData valueForKey:key];
            }
        }
    }
    
    return self;
}

@end