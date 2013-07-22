//
//  AppDelegate.h
//  Toolbox
//
//  Created by Jon Hester on 11/12/12.
//  Copyright (c) 2012 Jon Hester. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *primes;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSButton *genPrimeBtn;
@property (weak) IBOutlet NSButton *testWriteBtn;
@property (weak) IBOutlet NSTextField *writeSpeed;
@property (weak) IBOutlet NSTextField *readSpeed;
@property (weak) IBOutlet NSTextField *primeTime;
@property (weak) IBOutlet NSTextField *whatPrime;

//Backup
@property (weak) IBOutlet NSTextField *source;
@property (weak) IBOutlet NSTextField *destination;

- (IBAction)backupHelp:(id)sender;
- (IBAction)testWrite:(id)sender;
- (IBAction)startYes:(id)sender;
- (IBAction)genPrime:(id)sender;
- (IBAction)rsyncBtn:(id)sender;
@end
