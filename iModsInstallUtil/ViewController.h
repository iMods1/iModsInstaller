//
//  ViewController.h
//  iMods Installer
//
//  Created by Yannis on 1/27/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourController.h"

@interface ViewController : NSViewController <BonjourDelegate>
@property (weak) IBOutlet NSTextField *install_status;

@property BonjourController *bonjourController;
@property NSString *userName;
@property NSString *hostName;
@property NSString *password;
@property NSString *command;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSButton *shouldRemoveCydia;
@property (weak) IBOutlet NSTextField *statusLbl;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSPopUpButton *devicePicker;
@property (weak) IBOutlet NSTextField *passField;
@property (weak) IBOutlet NSButton *mainBtn;
@property NSMutableArray *iOSDevices;
@property (weak) IBOutlet NSTextField *connect_msg;

@property (weak) IBOutlet NSImageView *screen1_top;
@property (weak) IBOutlet NSImageView *screen2_iphone;
@property (weak) IBOutlet NSTextField *screen2_connected;
@property (weak) IBOutlet NSTextField *screen2_phone_name;
@property (weak) IBOutlet NSButton *install_button;
@property (weak) IBOutlet NSButton *help_button;
@property (weak) IBOutlet NSButton *help_button_openssh;

@end

