//
//  Services.h
//  MacMon
//
//  Created by dbader on 7/9/14.
//  Copyright (c) 2014 dbader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (copy) NSString *name;
@property (copy) NSString *pluginOutput;
@property (copy) NSString *currentState;
@property (copy) NSString *currentAttempt;
@property (copy) NSString *lastUpdate;

-(id)initWithDictionary:(NSDictionary *)serviceData;

@end