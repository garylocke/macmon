//
//  StatusViewController.h
//  MacMon
//
//  Created by Gary Locke on 7/9/14.
//  Copyright (c) 2014 Gary Locke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Host.h"

@interface StatusViewController : NSObject <NSOutlineViewDataSource>{
    IBOutlet NSOutlineView* statusTable;
}

@property (nonatomic, retain) IBOutlet NSOutlineView* statusTable;
@property (weak) IBOutlet NSTextField *serverUrl;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;

- (IBAction)connect:(id)sender;

@end