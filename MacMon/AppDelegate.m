//
//  AppDelegate.m
//  MacMon
//
//  Created by Gary Locke on 7/7/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize serverUrl;
@synthesize username;
@synthesize password;
@synthesize output;

NSURLConnection *urlConnection;

NSString *serverUrlString;
NSString *usernameString;
NSString *passwordString;
NSString *output;

NSString *statusUrl;

BOOL isConnected;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{}

- (IBAction)connect:(id)sender {
    
    serverUrlString = [NSString stringWithFormat:@"%@",[self.serverUrl stringValue]];
    usernameString = [NSString stringWithFormat:@"%@",[self.username stringValue]];
    passwordString = [NSString stringWithFormat:@"%@",[self.password stringValue]];
    
    statusUrl = [NSString stringWithFormat:@"%@/rss/rss.json",[self.serverUrl stringValue]];
    
    NSURL *url = [NSURL URLWithString:serverUrlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (IBAction)dataButton:(id)sender {
    [self getServerStatusData];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge previousFailureCount] > 1)
    {
        NSLog(@"auth failed");
    }
    else
    {
        NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:usernameString password:passwordString persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    isConnected = true;
    NSLog(@"Connected");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Could not authenticate to server.");
}

- (void)getServerStatusData{
    if(isConnected){
        NSString *urlString = [NSString stringWithFormat:@"%@",statusUrl];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            //NSLog(@"%@",response);
            
            //NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            //NSLog(@"%@",dataString);

            NSError *err = nil;
            NSDictionary *statusDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];

//            NSDictionary *hosts = [statusDictionary objectForKey:@"hosts"];
//            NSDictionary *firstHostValue = [hosts valueForKey:@"micro.synergeticmarketing.net"];
//            NSString *hostName = [firstHostValue valueForKey:@"host_name"];

            for(NSString *key in statusDictionary){
                id value = [statusDictionary objectForKey:key];
                if([value isKindOfClass:[NSDictionary class]]){
                    NSLog(@"dictionary found");
                } else if([value isKindOfClass:[NSString class]]){
                    NSLog(@"string found");
                }
            }
        }] resume];
    }
}

@end