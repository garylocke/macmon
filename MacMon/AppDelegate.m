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

            NSError *err = nil;
            NSDictionary *statusDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];

            // Outer objects (containing hosts or services)
            for(NSString *iKey in statusDictionary)
            {
                id iVal = [statusDictionary objectForKey:iKey];
                if([iVal isKindOfClass:[NSDictionary class]])
                {
                    // Individual hosts/services and their check data
                    for(NSString *jKey in iVal)
                    {
                        id jVal = [iVal objectForKey:jKey];
                        if([jVal isKindOfClass:[NSDictionary class]])
                        {
                            // Check properties
                            for(NSString *kKey in jVal)
                            {
                                id kVal = [jVal objectForKey:kKey];
                                if([kVal isKindOfClass:[NSDictionary class]])
                                {
                                    // Property shouldn't be a dictionary but you never know.
                                    for(NSString *lKey in kVal)
                                    {
                                        id lVal = [kVal objectForKey:lKey];
                                        NSLog(@"%@: %@",lKey,lVal);
                                    }
                                }
                                else
                                {
                                    NSLog(@"%@: %@",kKey,kVal);
                                }
                            }
                        }
                        else if([jVal isKindOfClass:[NSString class]])
                        {
                            NSLog(@"%@: %@",jKey,jVal);
                        }
                    }
                }
                else if([iVal isKindOfClass:[NSString class]])
                {
                    NSLog(@"%@: %@",iKey,iVal);
                }
            }
        }] resume];
    }
}

@end