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
			NSString *name = getDisplayName( dest );
			NSLog( @"%@", name );
			
			if( [name isEqualToString: IAC_NAME] )
			{
				self.iac = dest;
			}
		}
	}
	
	if( self.iac != (MIDIEndpointRef) NULL )
		NSLog(@"IAC found!");
	
	return NULL;
}

// http://stackoverflow.com/questions/10572747/why-doesnt-this-simple-coremidi-program-produce-midi-output

- (void) sendTestPackets
{
    char pktBuffer[1024];
    MIDIPacketList* pktList = (MIDIPacketList*) pktBuffer;
    MIDIPacket     *pkt;
    Byte            noteOn[]  = {0x90, 0x3c, 0x40};
    Byte            noteOff[] = {0x80, 0x3c, 0x40};
	
	Float64 f = AudioGetHostClockFrequency();
	UInt64 t = AudioGetCurrentHostTime();
	
    pkt = MIDIPacketListInit( pktList );
    pkt = MIDIPacketListAdd( pktList, 1024, pkt, t + 0 * f, 3, noteOn );
    pkt = MIDIPacketListAdd( pktList, 1024, pkt, t + 1 * f, 3, noteOff );
	
	MIDISend( self.outPort, self.iac, pktList );
}

NSString *getDisplayName( MIDIObjectRef object )
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
		return nil;
	return (NSString *)CFBridgingRelease(name);
}

@end
