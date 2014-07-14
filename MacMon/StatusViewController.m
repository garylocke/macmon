//
//  StatusViewController.m
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import "StatusViewController.h"

@implementation StatusViewController

NSURLConnection *urlConnection;

NSString *serverUrlString;
NSString *usernameString;
NSString *passwordString;

NSString *statusUrl;

BOOL isConnected;

@synthesize statusTable;

NSMutableArray *hosts;

// Initalize View Controller (should not happen until hosts/services arrays are populated).
-(id)init{
    self = [super init];
    if(self){
    
        // Array to store hosts.
        hosts = [[NSMutableArray alloc] init];
        
        // Sample host.
        NSMutableDictionary *host1Dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [host1Dict setObject:@"Sample Host" forKey:@"host_name"];
        [host1Dict setObject:@"Good" forKey:@"current_state"];
        [host1Dict setObject:@"1" forKey:@"current_attempt"];
        [host1Dict setObject:@"00:00:00" forKey:@"last_update"];
        
        // Sample dictionary of checks to add to host.
        NSMutableDictionary *serv1Dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [serv1Dict setObject:@"Sample Service" forKey:@"service_description"];
        [serv1Dict setObject:@"Bad" forKey:@"current_state"];
        [serv1Dict setObject:@"3" forKey:@"current_attempt"];
        [serv1Dict setObject:@"00:00:00" forKey:@"last_update"];
        
        // Add sample service to sample host.
        NSMutableArray *services = [NSMutableArray arrayWithObjects:serv1Dict, nil];
        [host1Dict setObject:services forKey:@"services"];
        

        // Create new sample host.
        Host *host1 = [[Host alloc] initWithDictionary:host1Dict];
        
        // Add sample host to hosts array.
        [hosts addObject:host1];
    
    
    }
    return self;
}

// Called when the Connect button is clicked.
// TODO: Add form validation.
- (IBAction)connect:(id)sender {
    
    serverUrlString = [NSString stringWithFormat:@"%@",[self.serverUrl stringValue]];
    usernameString = [NSString stringWithFormat:@"%@",[self.username stringValue]];
    passwordString = [NSString stringWithFormat:@"%@",[self.password stringValue]];
    
    statusUrl = [NSString stringWithFormat:@"%@/rss/rss.json",[self.serverUrl stringValue]];
    
    NSURL *url = [NSURL URLWithString:serverUrlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

// Called when an NSURLConnection is prompted for HTTP authentication.
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

// Called when an NSURLConnection finishes loading.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    isConnected = true;
    NSLog(@"Connected!");
    [self getServerStatusData];
}

// Called if an NSURLConnection fails.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Could not authenticate to server.");
}

// Called after a successful connection to the Nagios server is made.
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
            NSMutableArray *newHosts = [[NSMutableArray alloc] init];
            
            NSLog(@"Processing...");
            
            // Loop through hosts, creating a Host instance for each.
            for(NSDictionary *host in hostData)
            {
                Host *newHost = [[Host alloc] initWithDictionary:host];
                [newHosts addObject:newHost];
            }
            
            NSLog(@"Retrieved service data for %lu host(s).",[hosts count]);
            
            // Update hosts array.
            hosts = newHosts;
            
            // Reload table data.
            [statusTable reloadData];
            
        }] resume];
    }
}

/*
 * Methods called as the data source for the NSOutlineView.
 */
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return !item ? [hosts count] : [[item services] count];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if(!item)
        return NO;
    else if([item respondsToSelector:@selector(services)] && [[item services] count] != 0)
        return YES;
    return NO;
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(!item)
        return [hosts objectAtIndex:index];
    else if([item respondsToSelector:@selector(services)])
        return [[item services] objectAtIndex:index];
    return nil;
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    //NSLog(@"outlineView:objectValueForTableColumn:byItem runs for item:");
    //NSLog(@"%@",[item name]);
    if([[tableColumn identifier] isEqualToString:@"name"])
        return [item name];
    else if([[tableColumn identifier] isEqualToString:@"current_state"])
        return [item currentState];
    else if([[tableColumn identifier] isEqualToString:@"current_attempt"])
        return [item currentAttempt];
    else if([[tableColumn identifier] isEqualToString:@"last_update"])
        return [item lastUpdate];
    return @"Toasty!";
}

@end
