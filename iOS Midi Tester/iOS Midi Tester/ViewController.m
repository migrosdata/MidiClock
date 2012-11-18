//
//  ViewController.m
//  iMidiFinder
//
//  Created by Olivier Scherler on 11.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "ViewController.h"

#import <CoreMIDI/CoreMIDI.h>
#import <CoreMIDI/MIDINetworkSession.h>

@interface ViewController ()

@end

@implementation ViewController

NSString *getName(MIDIObjectRef object);
NSString *getDisplayName(MIDIObjectRef object);

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSString *getName(MIDIObjectRef object)
{
	// Returns the name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyName, &name))
		return nil;
	return (NSString *)CFBridgingRelease(name);
}

NSString *getDisplayName(MIDIObjectRef object)
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
		return nil;
	return (NSString *)CFBridgingRelease(name);
}

- (void) appendToConsole: (NSString *) string
{
	_console.text = [_console.text stringByAppendingString: string];
}

- (void) method1
{
	[self appendToConsole: @"Method 1:\n"];
	
	// How many MIDI devices do we have?
	ItemCount deviceCount = MIDIGetNumberOfDevices();
	
	// Iterate through all MIDI devices
	for (ItemCount i = 0 ; i < deviceCount ; ++i)
	{
		// Grab a reference to current device
		MIDIDeviceRef device = MIDIGetDevice(i);
		[self appendToConsole: [NSString stringWithFormat: @"Device: %@\n", getName(device)]];
		
	    // Is this device online? (Currently connected?)
		SInt32 isOffline = 0;
		MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &isOffline);
		[self appendToConsole: [NSString stringWithFormat: @" is online: %s\n", (isOffline ? "No" : "Yes")]];
		
		// How many entities do we have?
		ItemCount entityCount = MIDIDeviceGetNumberOfEntities(device);
		
		// Iterate through this device's entities
		for (ItemCount j = 0 ; j < entityCount ; ++j) {
			
			// Grab a reference to an entity
			MIDIEntityRef entity = MIDIDeviceGetEntity(device, j);
			[self appendToConsole: [NSString stringWithFormat: @"  Entity: %@\n", getName(entity)]];
			
			// Iterate through this device's source endpoints (MIDI In)
			ItemCount sourceCount = MIDIEntityGetNumberOfSources(entity);
			for (ItemCount k = 0 ; k < sourceCount ; ++k) {
				
				// Grab a reference to a source endpoint
				MIDIEndpointRef source = MIDIEntityGetSource(entity, k);
				[self appendToConsole: [NSString stringWithFormat: @"    Source: %@\n", getName(source)]];
			}
			
			// Iterate through this device's destination endpoints
			ItemCount destCount = MIDIEntityGetNumberOfDestinations(entity);
			for (ItemCount k = 0 ; k < destCount ; ++k) {
				
				// Grab a reference to a destination endpoint
				MIDIEndpointRef dest = MIDIEntityGetDestination(entity, k);
				[self appendToConsole: [NSString stringWithFormat: @"    Destination: %@\n", getName(dest)]];
			}
		}
	}
	[self appendToConsole: @"\n\n"];
}

- (void) method2
{
	[self appendToConsole: @"Method 2:\n"];

	MIDINetworkSession* session = [MIDINetworkSession defaultSession];
	
	session.enabled = YES;
	session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
	
	MIDINetworkHost *host = [MIDINetworkHost hostWithName: @"toto" address: @"192.168.1.10" port: 5004];
	MIDINetworkConnection *conn = [MIDINetworkConnection connectionWithHost: host];
	
	BOOL success = [session addConnection: conn];
	
	[self appendToConsole: @"Iterate through destinations\n"];
	ItemCount destCount = MIDIGetNumberOfDestinations();
	for (ItemCount i = 0 ; i < destCount ; ++i) {
		
		// Grab a reference to a destination endpoint
		MIDIEndpointRef dest = MIDIGetDestination(i);
		if (dest != NULL)
		{
			[self appendToConsole: [NSString stringWithFormat: @"  Destination: %@\n", getDisplayName(dest)]];
		}
	}
	
	[self appendToConsole: @"Iterate through sources\n"];
	// Virtual sources and destinations don't have entities
	ItemCount sourceCount = MIDIGetNumberOfSources();
	for (ItemCount i = 0 ; i < sourceCount ; ++i) {
		
		MIDIEndpointRef source = MIDIGetSource(i);
		if (source != NULL) {
			[self appendToConsole: [NSString stringWithFormat: @"  Source: %@\n", getDisplayName(source)]];
		}
	}
	[self appendToConsole: @"\n\n"];
}

- (IBAction)toto:(id)sender {
}

- (IBAction)rescan:(id)sender
{
	_console.text = @"";

	[self method1];
	[self method2];
}

@end
