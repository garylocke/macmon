//
//  AppDelegate.h
//  MacMon
//
//  Created by Gary Locke on 7/7/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *serverUrl;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSTextField *output;

- (IBAction)connect:(id)sender;
- (IBAction)dataButton:(id)sender;

@end
