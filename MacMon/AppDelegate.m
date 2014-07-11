//
//  AppDelegate.m
//  MacMon
//
//  Created by Gary Locke on 7/7/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusViewController.h"
#import "Host.h"
#import "Service.h"

@implementation AppDelegate

NSURLConnection *urlConnection;

NSString *serverUrlString;
NSString *usernameString;
NSString *passwordString;

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
    NSLog(@"Connected!");
    [self getServerStatusData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Could not authenticate to server.");
}

- (void)getServerStatusData{
    if(isConnected){
        
        NSLog(@"Getting data...");
        
        // Get status URL in string format for request and build URL.
        NSString *urlString = [NSString stringWithFormat:@"%@",statusUrl];
        NSURL *url = [NSURL URLWithString:urlString];
        
        // Open session and get data for request.
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){

            // Retrieve JSON data and store in NSDictionary object.
            NSError *err = nil;
            NSDictionary *hostData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            // Array to contain all Host instances.
            NSMutableArray *hosts = [[NSMutableArray alloc] init];
            
            NSLog(@"Processing...");
            
            // Loop through hosts, creating a Host instance for each.
            for(NSDictionary *host in hostData)
            {
                Host *newHost = [[Host alloc] initWithDictionary:host];
                [hosts addObject:newHost];
            }
            
            NSLog(@"Retrieved service data for %lu host(s).",[hosts count]);
            
            // Set static array values in StatusViewController class.
            StatusViewController.hosts = hosts;
            //StatusViewController.services = services;
            
        }] resume];
    }
}

@end