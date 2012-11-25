//
//  AppDelegate.h
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MCMidiManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (retain) MCMidiManager *midi;

@end
