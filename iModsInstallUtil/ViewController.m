//
//  ViewController.m
//  iMods Installer
//
//  Created by Yannis on 1/27/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import "ViewController.h"

//TODO: add message sayign connect to same wifi network

@implementation ViewController
NSTask *taskObject;
- (IBAction)get_started:(id)sender {
    NSUInteger selected = [self.devicePicker indexOfSelectedItem];
    NSDictionary *device = self.iOSDevices[selected];
    NSString *dvName = [device objectForKey:@"Device_Name"];
    NSString *properName = [[[dvName componentsSeparatedByString:@".local"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    self.screen2_phone_name.stringValue = properName;
    self.devicePicker.hidden = YES;
    self.screen2_iphone.hidden = NO;
    self.screen2_connected.hidden = NO;
    self.screen2_phone_name.hidden = NO;
    self.progressIndicator.hidden = YES;
    self.mainBtn.hidden = YES;
    self.install_button.hidden = NO;
    self.statusLbl.hidden = YES;
    self.screen1_top.hidden = YES;
    self.help_button.hidden = NO;
    self.passField.hidden = NO;
}
- (IBAction)why_no_install:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:@"The iMods Beta requires you have OpenSSH on your device to run. If you do not have OpenSSH installed please open your current package manager on your iOS device and install the package `OpenSSH`. Afterwards come back to the iMods Installer."];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

/*-(void)scpAndTextWithPath:(NSString *)debPath andFile:(NSString *)debName {
    self.userName = @"root";
    NSUInteger selected = [self.devicePicker indexOfSelectedItem];
    NSDictionary *device = self.iOSDevices[selected];
    NSString *address = [device objectForKey:@"IP_Address"];
    self.hostName = address;
    NSString *pass = @"";//[self.passField stringValue];
    if (pass == nil) {
        pass = @"alpine";
    }
    self.password = pass;
    NSString *ssBundle = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/sshpass"];
    NSString *cmd = [ssBundle stringByAppendingString:[NSString stringWithFormat:@" -p '%@' scp %@ root@%@:/var/mobile/Documents/%@", self.password, debPath, self.hostName, debName]];
    const char* exec = [cmd UTF8String];
    system(exec);
}*/

- (NSString *)commandWithReturn:(NSString *)command andArguments:(NSArray *)arguments {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: command]; // Tell the task to execute the ssh command
    [task setArguments: arguments];
    //NSLog(@"%@", task);
    
    
    // Set the arguments for ssh to contain only your command. If other configuration is necessary, see the ssh(1) man page.
    
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading]; // This file handle is a reference to the output of the ssh command
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return string;
    
}
- (IBAction)helpMeRoot:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:@"Your device has a root password. If you have changed it please enter what you changed it to in this field. If you havn't changed it or do not know what it is disregard this message and leave this box blank."];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (IBAction)install:(NSButton *)sender {
    self.help_button.hidden = YES;
    self.passField.hidden = YES;
    self.screen2_iphone.hidden = YES;
    self.screen2_connected.hidden = YES;
    self.screen2_phone_name.hidden = YES;
    self.install_button.hidden = YES;
    self.progressBar.hidden = NO;
    [self.install_status setStringValue:@"Initializing"];
    self.install_status.hidden = NO;
    self.userName = @"root";
    self.password = @"alpine";
    NSUInteger selected = [self.devicePicker indexOfSelectedItem];
    NSDictionary *device = self.iOSDevices[selected];
    NSString *address = [device objectForKey:@"IP_Address"];
    self.hostName = address;
    if ([[self.passField stringValue] isEqualToString:@""]) {
        NSString *pass = @"alpine";//[self.passField stringValue];
        self.password = pass;
        NSString *cmd = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/sshpass"];
        NSArray *arguments = [NSArray arrayWithObjects: @"-p", pass, @"ssh", @"-o", @"StrictHostKeyChecking=no", [NSString stringWithFormat:@"root@%@", address], [NSString stringWithFormat:@"%@", @"date"], nil];
        NSString *dateS = [self commandWithReturn:cmd andArguments:arguments];
        if (dateS == nil) {
            [self.install_status setStringValue:@"Done"];
        } else {
            [self installationMechanism];
        }
    } else {
        NSLog(@"needed root");
        NSString *pass = [self.passField stringValue];
        self.password = pass;
        NSString *cmd = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/sshpass"];
        NSArray *arguments = [NSArray arrayWithObjects: @"-p", pass, @"ssh", @"-o", @"StrictHostKeyChecking=no", [NSString stringWithFormat:@"root@%@", self.hostName], [NSString stringWithFormat:@"%@", @"date"], nil];
        NSString *dateS = [self commandWithReturn:cmd andArguments:arguments];
        if (dateS != nil) {
            [self installationMechanism];
        }
    }
}

-(NSString *) getIPWithNSHost{
    NSString *stringAddress;
    NSArray *addresses = [[NSHost currentHost] addresses];
    for (NSString *anAddress in addresses) {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            stringAddress = anAddress;
            break;
        } else {
            stringAddress = @"IPv4 address not available" ;
        }
    }
    return stringAddress;
}

-(void)installationMechanism {
    dispatch_queue_t queue = dispatch_queue_create("com.example.MyQueue", NULL);
    dispatch_async(queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            float doub = 1*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
        });
        NSString *debName = @"com.Wunderkind.iMods_1.0_iphoneos-arm.deb";
        NSString *grepDebName = @"grep_2.21_iphoneos-arm.deb";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.install_status setStringValue:@"Downloading"];
            float doub = 2*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
        });
        NSString *debIPath = [NSString stringWithFormat:@"/var/mobile/Documents/%@", grepDebName];
        NSString *ipAddress = [self getIPWithNSHost];
        [self sshCommand:[NSString stringWithFormat:@"curl -s -o %@ http://%@:8080", debIPath, ipAddress]];
        [self sshCommand:[NSString stringWithFormat:@"dpkg -i %@", debIPath]];
        NSString *debInstallPath = [NSString stringWithFormat:@"/var/mobile/Documents/%@", debName];
        [self sshCommand:[NSString stringWithFormat:@"curl -s -o %@ http://%@:8080", debInstallPath, ipAddress]];
        [self sshCommand:[NSString stringWithFormat:@"dpkg -i %@", debInstallPath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.install_status setStringValue:@"Installing"];
            float doub = 3*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
        });
        [self sshCommand:[NSString stringWithFormat:@"rm %@", debInstallPath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.install_status setStringValue:@"Cleaning Up"];
            float doub = 4*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
        });
        
        //self.shouldRemoveCydia
        /*BOOL checkState = [self.shouldRemoveCydia state] == NSOnState;
        if (checkState) {
            [self sshCommand:@"dpkg -r cydia"];
            dispatch_async(dispatch_get_main_queue(), ^{
                float doub = 5*100;
                doub /= 7;
                [self.progressBar setDoubleValue:doub];
            });
        }*/
        dispatch_async(dispatch_get_main_queue(), ^{
            float doub = 6*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
        });
        [self sshCommand:@"su mobile -c uicache"]; //uicache && killall SpringBoard
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.install_status setStringValue:@"Updating Homescreen"];
            float doub = 7*100;
            doub /= 7;
            [self.progressBar setDoubleValue:doub];
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2);
            dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                [self.install_status setStringValue:@"Done. Quitting."];
                dispatch_time_t delay2 = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 3);
                dispatch_after(delay2, dispatch_get_main_queue(), ^(void){
                    [[NSApplication sharedApplication] terminate:self];
                });
            });
        });
    });
}

-(void)sshCommand:(NSString *)command {
    self.command = command;
    NSString *ssBundle = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/sshpass"];
    NSString *cmd = [ssBundle stringByAppendingString:[NSString stringWithFormat:@" -p%@ ssh -o StrictHostKeyChecking=no root@%@ %@", self.password, self.hostName, command]];
    const char* exec = [cmd UTF8String];
    system(exec);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.devicePicker.hidden = YES;
    self.screen2_iphone.hidden = YES;
    self.screen2_connected.hidden = YES;
    self.screen2_phone_name.hidden = YES;
    self.install_button.hidden = YES;
    self.mainBtn.hidden = YES;
    self.progressBar.hidden = YES;
    self.install_status.hidden = YES;
    self.help_button.hidden = YES;
    self.passField.hidden = YES;
    self.connect_msg.hidden = NO;
    //[self.statusLbl setStringValue:@"Finding your devices. Please make sure they're Unlocked and on the same network"];
    [self.progressIndicator startAnimation:self];
    self.bonjourController = [[BonjourController alloc] init];
    self.bonjourController.delegate = self;
    [self.bonjourController startBrowsing];
    self.iOSDevices = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (void)foundNearbyiOSDevice:(NSDictionary *)device {
    if (self.iOSDevices.count == 0) {
        [self.statusLbl setStringValue:@"Please select a device"];
        [self.progressIndicator stopAnimation:self];
        self.devicePicker.hidden = NO;
        self.progressIndicator.hidden = YES;
        self.mainBtn.hidden = NO;
        self.connect_msg.hidden = YES;
        self.help_button_openssh.hidden = YES;
    }
    if ([self.iOSDevices indexOfObject:device] == NSNotFound) {
        [self.iOSDevices addObject:device];
    }
    NSString *dvName = [device objectForKey:@"Device_Name"];
    NSString *properName = [[[dvName componentsSeparatedByString:@".local"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    [self.devicePicker addItemWithTitle:properName];
}

@end
