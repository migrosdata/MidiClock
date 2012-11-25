//
//  MCMidiManager.m
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "MCMidiManager.h"

@implementation MCMidiManager

- (id) init
{
	if( self = [super init] )
	{
		MIDIClientRef client = (MIDIClientRef) NULL;
		MIDIClientCreate( CLIENT_NAME, NULL, (__bridge void *)(self), &client );
		self.client = client;
		
		MIDIPortRef inPort = (MIDIPortRef) NULL;
		MIDIInputPortCreate( client, IN_PORT_NAME, NULL, (__bridge void *)(self), &inPort );
		self.inPort = inPort;
		
		MIDIPortRef outPort = (MIDIPortRef) NULL;
		MIDIOutputPortCreate( client, IN_PORT_NAME, &outPort );
		self.outPort = outPort;
	}
	
	return self;
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
