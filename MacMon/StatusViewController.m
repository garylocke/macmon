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
        NSMutableArray *services = [[NSMutableArray alloc] init];
        
        // Sample host.
        NSMutableDictionary *host1Dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [host1Dict setObject:@"Sample Good Host" forKey:@"host_name"];
        [host1Dict setObject:@"0" forKey:@"current_state"];
        [host1Dict setObject:@"1" forKey:@"current_attempt"];
        [host1Dict setObject:@"00:00:00" forKey:@"last_update"];
        
        // Sample dictionary of service details.
        NSMutableDictionary *serv1Dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [serv1Dict setObject:@"Sample Warning Service" forKey:@"service_description"];
        [serv1Dict setObject:@"WARNING: Service warning state." forKey:@"plugin_output"];
        [serv1Dict setObject:@"1" forKey:@"current_state"];
        [serv1Dict setObject:@"3" forKey:@"current_attempt"];
        [serv1Dict setObject:@"00:00:00" forKey:@"last_update"];
        
        NSMutableDictionary *serv2Dict = [[NSMutableDictionary alloc] initWithCapacity:4];
        [serv2Dict setObject:@"Sample Critical Service" forKey:@"service_description"];
        [serv2Dict setObject:@"CRITICAL: Service critical state." forKey:@"plugin_output"];
        [serv2Dict setObject:@"2" forKey:@"current_state"];
        [serv2Dict setObject:@"5" forKey:@"current_attempt"];
        [serv2Dict setObject:@"00:00:00" forKey:@"last_update"];
        
        // Add sample services to array.
        [services addObject:serv1Dict];
        [services addObject:serv2Dict];
        
        // Add sample service array to sample host.
        [host1Dict setObject:services forKey:@"services"];

        // Create new sample host.
        Host *host1 = [[Host alloc] initWithDictionary:host1Dict];
        
        // Add sample host to hosts array.
        [hosts addObject:host1];
        
        // Set update timer.
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getServerStatusData:) userInfo:nil repeats:YES];
    
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
        NSLog(@"auth failed");
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
    } else [self connect:self];
}

// Return item counts to outline view table.
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    return !item ? [hosts count] : [[item services] count];
}

// Return whether item is expandable.
-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if(!item)
        return NO;
    else if([item respondsToSelector:@selector(services)] && [[item services] count] != 0)
        return YES;
    return NO;
}

// Return item children.
-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(!item)
        return [hosts objectAtIndex:index];
    else if([item respondsToSelector:@selector(services)])
        return [[item services] objectAtIndex:index];
    return nil;
}

// Set display value for table columns.
-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if([[tableColumn identifier] isEqualToString:@"name"])
        return [item name];
    else if([[tableColumn identifier] isEqualToString:@"current_state"]){
        
        // If item is a Host, return strings that represent the current state value.
        if([item isKindOfClass:[Host class]]){
            NSString *state = [item currentState];
            if([state integerValue] == 0)
                return @"OK";
            else if([state integerValue] == 1)
                return @"WARNING";
            else if([state integerValue] == 2)
                return @"CRITICAL";
            return @"UNKNOWN";
        }
        
        // Otherwise, item must be a Service, so return the plugin output.
        else return [item pluginOutput];
    }
    else if([[tableColumn identifier] isEqualToString:@"current_attempt"])
        return [item currentAttempt];
    else if([[tableColumn identifier] isEqualToString:@"last_update"])
        return [item lastUpdate];
    return @"-";
}

// Colorize cells based on status.
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSString *state = [item currentState];
    if([state integerValue] == 0)
        [cell setBackgroundColor:[NSColor colorWithSRGBRed:0 green:1 blue:0 alpha:0.2]];
    else if([state integerValue] == 1)
        [cell setBackgroundColor:[NSColor colorWithSRGBRed:1 green:1 blue:0 alpha:0.2]];
    else if([state integerValue] == 2)
        [cell setBackgroundColor:[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:0.2]];
    else [cell setBackgroundColor:[NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:0.2]];
}

@end
