//
//  AppDelegate.h
//  KuaiPanTool
//
//  Created by Jinbo He on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate> {
    
    IBOutlet NSTextField     *_txtCodePath;
    IBOutlet NSTextField     *_txtInfoPlist;
    IBOutlet NSTextField     *_txtInitVersion;
    
    IBOutlet NSTextField     *_txtOutputPath;
    IBOutlet NSTextField     *_txtOutputFile;
    
    IBOutlet NSTextField     *_txtTestVersion;
    IBOutlet NSScrollView    *_txtLog; 

    IBOutlet NSProgressIndicator *_indicator;
}

@property (assign) IBOutlet NSWindow    *window;

- (IBAction)doSaveConfig:(id)sender;
- (IBAction)doCompileTest:(id)sender;
- (IBAction)doCompileDistribution:(id)sender;
- (IBAction)doClearLog:(id)sender;

- (IBAction)doSelectPath:(id)sender;

@end
