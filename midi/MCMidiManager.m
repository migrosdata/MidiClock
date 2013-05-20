//
//  MCMidiManager.m
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "MCMidiManager.h"
#import "MCMidiMessage.h"

@implementation MCMidiManager

- (id) init
{
	if( self = [super init] )
	{
		MIDIClientRef client;
		MIDIClientCreate( CLIENT_NAME, NULL, (__bridge void *)(self), &client );
		self.client = client;
		
		MIDIPortRef inPort;
		MIDIInputPortCreate( client, IN_PORT_NAME, NULL, (__bridge void *)(self), &inPort );
		self.inPort = inPort;
		
		MIDIPortRef outPort;
		MIDIOutputPortCreate( client, IN_PORT_NAME, &outPort );
		self.outPort = outPort;
	}
	
	return self;
}

- (NSArray *) listDestinations
{
	ItemCount destCount = MIDIGetNumberOfDestinations();
	// NSMutableArray *destinations = [NSMutableArray arrayWithCapacity: destCount];
	
	for( ItemCount i = 0; i < destCount; i++ )
	{
		// Grab a reference to a destination endpoint
		MIDIEndpointRef dest = MIDIGetDestination( i );
		if( dest )
		{
			NSString *name = getDisplayName( dest );
			NSLog( @"%@", name );
			
			//if( [name isEqualToString: IAC_NAME] )
			if( ! self.iac )
				self.iac = dest;
		}
	}
	
	if( self.iac )
		NSLog(@"IAC found!");
	
	return NULL;
}

// http://stackoverflow.com/questions/10572747/why-doesnt-this-simple-coremidi-program-produce-midi-output
// http://stackoverflow.com/questions/7668390/osx-core-midi-calling-midipacketlistadd-from-nstimer
// http://stackoverflow.com/questions/675626/coreaudio-audiotimestamp-mhosttime-clock-frequency

- (void) sendTestPackets
{
	char             pktBuffer[1024];
	MIDIPacketList   *pktList = (MIDIPacketList *) pktBuffer;
	MIDIPacket       *pkt;
	Byte             notes[]   = { 0x3c, 0x3e, 0x40, 0x41, 0x43, 0x45, 0x47, 0x48 };
	Byte             noteOn[]  = { 0x90, 0x3c, 0x7f };
	Byte             noteOff[] = { 0x80, 0x3c, 0x7f };
	
	MCTimeBase *base = [[MCTimeBase alloc] initWithTempo: 120];

	UInt64 d = [base beatTicks];
	UInt64 t = mach_absolute_time() + d;
	
	pkt = MIDIPacketListInit( pktList );
	for( int i = 0; i < 8; i++ )
	{
		noteOn[1]  = notes[ i ];
		noteOff[1] = notes[ i ];

		pkt = MIDIPacketListAdd( pktList, sizeof( pktBuffer ), pkt, t, 3, noteOn );
		pkt = MIDIPacketListAdd( pktList, sizeof( pktBuffer ), pkt, t + d, 3, noteOff );

		t += d;
	}
	
	// MIDISend( self.outPort, self.iac, pktList );
	
	[self parseMIDIPacketList: pktList];
}

- (void) parseMIDIPacketList: (MIDIPacketList *) list
{
	MIDIPacket *packet = &list->packet[0];

	for( int i = 0; i < list->numPackets; i++ )
	{
		[self parseMIDIPacket: packet];
		packet = MIDIPacketNext( packet );
	}
}

- (kMIDIType) getTypeFromStatusByte: (Byte) inStatus
{
	if( ( inStatus < 0x80 )
		|| ( inStatus == 0xF4 )
		|| ( inStatus == 0xF5 )
		|| ( inStatus == 0xF9 )
		|| ( inStatus == 0xFD ) ) return MS_InvalidType; // data bytes and undefined.
	if( inStatus < 0xF0 ) return (kMIDIType)( inStatus & 0xF0 );   // Channel message, remove channel nibble.
	else return (kMIDIType)inStatus;
}

- (void) parseMIDIPacket: (MIDIPacket *) packet
{
	NSLog( @"Packet (%d)", packet->length );
	
	NSMutableArray *messages = [NSMutableArray array];
	MCMidiMessage *message;
	
	BOOL messageStarted = NO;
	BOOL inRunning = NO;
	Byte runningStatus = NULL;
	for( UInt16 i = 0; i < packet->length; i++ )
	{
		Byte byte = packet->data[i];
		kMIDIType status = [self getTypeFromStatusByte: byte];
		
		if( ! messageStarted )
		{
			if( status == MS_InvalidType )
			{
				NSLog( @"Invalid status: %d", byte );
				return;
			}

			// now we have a valid status byte
			messageStarted = YES;
			runningStatus = status;
			
			message = [[MCMidiMessage alloc] init];
			[message setTimeStamp: packet->timeStamp];
			[message setStatus: status];
			
			[messages addObject: message];
		}
		
	}
}
- (void) sendTestClockPackets
{
	// create and start a time base
	MCTimeBase *base = [[MCTimeBase alloc] initWithTempo: 120];
	[base start];

	// start sending clock packets
	[self performSelector: @selector(clocksForOneSecond:) withObject: base];
}

// send clock packets for one second and schedule the next batch
- (void) clocksForOneSecond: (MCTimeBase *) base
{
	NSLog(@"clocksForOneSecond");
	
	MIDIPacketList   *pktList;

	// send the packet list and free it
	pktList = [base clocksForDuration: 1000];
	MIDISend( self.outPort, self.iac, pktList );
	free( pktList );

	// schedule the next 1-second batch
	[self performSelector: @selector(clocksForOneSecond:)
			   withObject: base
			   afterDelay: 0.9 * [base ticksToNextClock] / [base ticksPerSecond]
	];
}

NSString *getDisplayName( MIDIObjectRef object )
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if( MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name ) != noErr )
		return nil;

	return (NSString *)CFBridgingRelease( name );
}

@end
