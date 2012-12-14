//
//  MCTimeBase.m
//  iOS Midi Tester
//
//  Created by Olivier Scherler on 07.12.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import "MCTimeBase.h"

@implementation MCTimeBase

@synthesize tempo;

- (id) init
{
	return [self initWithTempo: MC_DEFAULT_TEMPO];
}

// designated initialiser
- (id) initWithTempo: (UInt32) new_tempo
{
	if( self = [super init] )
	{
		// calculate ticks per second based on mach timebase
		mach_timebase_info_data_t ns_in_tick;
		mach_timebase_info( &ns_in_tick );
		ticks_per_second = ns_in_tick.denom * 1e9 / ns_in_tick.numer;
		
		// ensure the timebase is stopped
		[self stop];

		// set the tempo
		self.tempo = new_tempo;
	}
	
	return self;
}

// set the tempo and calculate ticks per clock
- (void) setTempo: (UInt32) new_tempo
{
	tempo = new_tempo;
	ticks_in_clock = ticks_per_second / [self clocksPerSecondForTempo: new_tempo];
}

// calculate clocks per second for the given tempo
- (double) clocksPerSecondForTempo: (UInt32) new_tempo
{
	// 24 midi clock pulses per quarter note
	return new_tempo * MC_CLOCKS_PER_BEAT / 60;
}

- (void) start
{
	self.start_time = mach_absolute_time();
	current_clock = 0;
}

- (void) stop
{
	self.start_time = 0;
	current_clock = 0;
}

- (BOOL) isStarted
{
	return ( self.start_time != 0 );
}

- (UInt64) nextClock
{
	UInt64 t;
	
	current_clock += 1;
	t = _start_time + current_clock * ticks_in_clock;
	
	return t;
}

- (UInt64) clockTicks
{
	return ticks_in_clock;
}

- (UInt64) beatTicks
{
	return ticks_in_clock * MC_CLOCKS_PER_BEAT;
}

// http://stackoverflow.com/questions/8748582/pass-pointer-to-first-packet-between-methods-obj-c
- (MIDIPacketList *) clocksForDuration: (UInt32) ms
{
	// clock: 0xf8, start: 0xfa, stop: 0xfc
	Byte      clock[]  = { 0xf8 };

	// b/min ms ck/b min/s s/ms -> ck
	UInt32    clockPacketCount = ms * tempo * MC_CLOCKS_PER_BEAT / ( 60 * 1000 );
	UInt32    packetBufferSize = MC_PACKET_LIST_HEADER_SIZE + clockPacketCount * MC_CLOCK_PACKET_SIZE;
	
	if( ! [self isStarted] )
		[self start];
	
	UInt64 t = _start_time + current_clock * ticks_in_clock;
	
	// potential alignment problem on iOS
	// http://lists.apple.com/archives/coreaudio-api/2011/Jun/msg00029.html
	MIDIPacketList *pktList = malloc( packetBufferSize );
	MIDIPacket *pkt = MIDIPacketListInit( pktList );

	for( int i = 0; i < clockPacketCount; i++ )
	{
		pkt = MIDIPacketListAdd( pktList, packetBufferSize, pkt, t, 1, clock );
		t = [self nextClock];
	}
	
	// needs to be free()’ed by caller
	return pktList;
}

@end
