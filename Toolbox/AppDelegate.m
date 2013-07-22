//
//  AppDelegate.m
//  Toolbox
//
//  Created by Jon Hester on 11/12/12.
//  Copyright (c) 2012 Jon Hester. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //NSLog(@"%d",[self getFreeSpace]);
    [self getFreeSpace];
    
}

- (BOOL)isPrime:(long int)prime
{
    if (prime <= 1) {return false;}
    if (prime == 2) {return true;}
    if (prime % 2 == 0) {return false;}

    for (int i = 3; i <= sqrt(prime); i+=2) {
        if (prime % i == 0) {
            return false;
        }
    }
    return true;
}

- (void)getFreeSpace {
    // this works
    NSError *error = nil;
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                           error:&error];
    unsigned long long freeSpace = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    NSLog(@"free disk space: %dGB", (int)(freeSpace / 1073741824));
}

- (IBAction)backupHelp:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Why use rsync?", nil)
                                     defaultButton:NSLocalizedString(@"OK", nil)
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:NSLocalizedString(@"Rsync preserves permissions, timestamps, owner, group, links, device files, and special files. It's fast and if interrupted it will resume where it left off.  It even performs checksums on all copied files to ensure their integrity.", nil)];
    [alert runModal];

}

- (IBAction)testWrite:(id)sender {
    _testWriteBtn.enabled=NO;
    
    //tempdirectory
    NSString *tempDirectoryTemplate =
    [NSTemporaryDirectory() stringByAppendingPathComponent:@"toolbox.XXXXXX"];
    const char *tempDirectoryTemplateCString =
    [tempDirectoryTemplate fileSystemRepresentation];
    char *tempDirectoryNameCString =
    (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
    strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
    
    char *result = mkdtemp(tempDirectoryNameCString);
    if (!result)
    {
        // handle directory creation failure
    }
    
    NSString *tempDirectoryPath =
    [[NSFileManager defaultManager]
     stringWithFileSystemRepresentation:tempDirectoryNameCString
     length:strlen(result)];
    free(tempDirectoryNameCString);
    NSLog(tempDirectoryPath);
    // Setup process
    // Set up the process
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@"/usr/bin/time"];
    [t setCurrentDirectoryPath:tempDirectoryPath];
    [t setArguments:[NSArray arrayWithObjects:@"dd",@"if=/dev/zero",@"bs=1024k", @"of=tstfile", @"count=1024",nil]];
    
    // Set the pipe to the standard output and error to get the results of the command
    NSPipe *p = [[NSPipe alloc] init];
    [t setStandardOutput:p];
    [t setStandardError:p];
    
    // Launch (forks) the process
    [t launch]; // raises an exception if something went wrong
    
    // Prepare to read
    NSFileHandle *readHandle = [p fileHandleForReading];
    NSData *inData = nil;
    NSMutableData *totalData = [[NSMutableData alloc] init];
    
    while ((inData = [readHandle availableData]) &&
           [inData length]) {
        [totalData appendData:inData];
    }
    
    // Polls the runloop until its finished
    [t waitUntilExit];
    
    
    NSString *output = [[NSString alloc] initWithData:totalData encoding:NSUTF8StringEncoding];
    NSLog(@"Terminationstatus: %d", [t terminationStatus]);
    NSLog(@"Data recovered: %@", output);
    
    NSScanner *scanner = [NSScanner scannerWithString:output];
    //NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

    
    [scanner scanUpToString:@"(" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];
    int number;
    [scanner scanInt:&number];
    [_writeSpeed setStringValue:[NSString stringWithFormat:@"%d MB/second",number/1024/1024]];
    NSLog(@"%d MB/second",number/1024/1024);
    
    //Read Test
    // Setup process
    // Set up the process
    t = [[NSTask alloc] init];
    [t setLaunchPath:@"/usr/bin/time"];
    [t setArguments:[NSArray arrayWithObjects:@"dd",[NSString stringWithFormat:@"if=%@/tstfile",tempDirectoryPath],@"bs=1024k", @"of=/dev/null", @"count=1024",nil]];
    
    // Set the pipe to the standard output and error to get the results of the command
    p = [[NSPipe alloc] init];
    [t setStandardOutput:p];
    [t setStandardError:p];
    
    // Launch (forks) the process
    [t launch]; // raises an exception if something went wrong
    
    // Prepare to read
    readHandle = [p fileHandleForReading];
    inData = nil;
    totalData = [[NSMutableData alloc] init];
    
    while ((inData = [readHandle availableData]) &&
           [inData length]) {
        [totalData appendData:inData];
    }
    
    // Polls the runloop until its finished
    [t waitUntilExit];
    
    
    output = [[NSString alloc] initWithData:totalData encoding:NSUTF8StringEncoding];
    NSLog(@"Terminationstatus: %d", [t terminationStatus]);
    NSLog(@"Data recovered: %@", output);
    
    scanner = [NSScanner scannerWithString:output];
    //NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    
    [scanner scanUpToString:@"(" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];
    [scanner scanInt:&number];
    [_readSpeed setStringValue:[NSString stringWithFormat:@"%d MB/second",number/1024/1024]];
    NSLog(@"%d MB/second",number/1024/1024);
    
    t = [[NSTask alloc] init];
    [t setLaunchPath:@"/bin/rm"];
    [t setArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/tstfile",tempDirectoryPath],nil]];
    
    // Set the pipe to the standard output and error to get the results of the command
    p = [[NSPipe alloc] init];
    [t setStandardOutput:p];
    [t setStandardError:p];
    
    // Launch (forks) the process
    [t launch]; // raises an exception if something went wrong
    
    // Prepare to read
    readHandle = [p fileHandleForReading];
    inData = nil;
    totalData = [[NSMutableData alloc] init];
    
    while ((inData = [readHandle availableData]) &&
           [inData length]) {
        [totalData appendData:inData];
    }
    
    // Polls the runloop until its finished
    [t waitUntilExit];
    _testWriteBtn.enabled=YES;
    
    output = [[NSString alloc] initWithData:totalData encoding:NSUTF8StringEncoding];
    NSLog(@"Terminationstatus: %d", [t terminationStatus]);
    NSLog(@"Data recovered: %@", output);
    
    
}

- (IBAction)startYes:(id)sender {
    NSString *a = @"Yes > /dev/null";
    NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"", a];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    for (int i = 0; i < [[NSProcessInfo processInfo] processorCount]; i++) {
        [as executeAndReturnError:nil];
    }
    
}

- (IBAction)genPrime:(id)sender {
    NSDate *methodStart = [NSDate date];

    _genPrimeBtn.enabled = NO;
    void (^progressBlock)(void);
    progressBlock = ^{
        [_progressBar setDoubleValue:0.0];
        [_progressBar startAnimation:sender];
        int count = 0;
        int seconds = 0;
        long int num =  1000000000000;
        int minutes = [_whatPrime integerValue];
        while (seconds <= minutes) {
            
            if ([self isPrime:num]) {
                count++;
                [_primes setStringValue:[NSString stringWithFormat:@"%ld",num]];
                
            }
            num++;
            // Update progress bar
            double progr = (double)seconds / (double)minutes;
            [_progressBar setDoubleValue:progr];
            NSLog(@"progr: %f", progr); // Logs values between 0.0 and 1.0
            //update timer
            seconds = [[NSDate date] timeIntervalSinceDate:methodStart];
            [_primeTime setStringValue:[NSString stringWithFormat:@"%d:%02d",seconds / 60,seconds % 60]];
            
        }
        _genPrimeBtn.enabled = YES;
    };
    //Finally, run the block on a different thread.
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(queue,progressBlock);
    
    NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
}

- (IBAction)rsyncBtn:(id)sender {
    NSString *a = [NSString stringWithFormat:@"sudo rsync -avzh --progress --partial %@ %@",[_source stringValue],[_destination stringValue]];
    NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"", a];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
    
}
@end
