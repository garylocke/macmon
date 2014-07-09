//
//  Services.h
//  MacMon
//
//  Created by dbader on 7/9/14.
//  Copyright (c) 2014 dbader. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (copy) NSString *hostName;
@property (copy) NSString *serviceDescription;
@property (copy) NSString *pluginOutput;
@property (copy) NSString *currentState;
@property (copy) NSString *currentStateDetails;
@property (copy) NSString *attempt;
@property (copy) NSString *lastUpdated;

-(id)initWithDictionary:(NSDictionary *)serviceData;

@end