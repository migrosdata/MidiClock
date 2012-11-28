//
//  ViewController.m
//  iMidiFinder
//
//  Created by Olivier Scherler on 11.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "ViewController.h"

#import <CoreMIDI/CoreMIDI.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize midi;

- (void) viewDidLoad
{
	[super viewDidLoad];

	// Needed to be able to connect to the iPad from MIDI Network Setup in Ausio MIDI Setup
	// We need to connect manually from the Mac side
	MIDINetworkSession* session = [MIDINetworkSession defaultSession];
	
	session.enabled = YES;
	session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;

	// Do any additional setup after loading the view, typically from a nib.
	midi = [[MCMidiManager alloc] init];
	[midi listDestinations];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction) rescan: (id) sender
{
}

- (IBAction) play: (id) sender
{
	[midi sendTestPackets];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

@end
