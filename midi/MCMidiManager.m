//
//  MCMidiManager.m
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "MCMidiManager.h"

@implementation MCMidiManager

NSString *getDisplayName( MIDIObjectRef object )
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
		return nil;
	return (NSString *)CFBridgingRelease(name);
}

- (NSArray *) listDestinations
{
	ItemCount destCount = MIDIGetNumberOfDestinations();
	// NSMutableArray *destinations = [NSMutableArray arrayWithCapacity: destCount];
	
	for( ItemCount i = 0; i < destCount; ++i )
	{
		// Grab a reference to a destination endpoint
		MIDIEndpointRef dest = MIDIGetDestination( i );
		if( dest != (MIDIEndpointRef) NULL )
		{
			NSLog( @"%@",
				  getDisplayName( dest )
			);
		}
	}
	
	return NULL;
}

@end
