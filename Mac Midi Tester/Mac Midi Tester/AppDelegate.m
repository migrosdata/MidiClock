//
//  AppDelegate.m
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize midi;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	midi = [[MCMidiManager alloc] init];
	
	[midi listDestinations];
}

@end
