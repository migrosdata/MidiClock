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
		mach_timebase_info( &ns_in_tick );
		
		self.tempo = new_tempo;
	}
	
	return self;
}

// tempo = 120 bpm
// 2 quarter notes per second
// 24 midi clock pulses per quarter note
// 48 midi clock pulses per second

// d : tick
// dns : ns
// d = dns / f -> f = dns / d = ns/tick
// 48 pulse / second -> 1000/48 ms/pulse = 21 ms/pulse

- (void) setTempo: (UInt32) new_tempo
{
	tempo = new_tempo;

	// s/min ns/s b/ck min/b tk/ns = tk/ck
	ticks_in_clock = 60 * 1e9 * ns_in_tick.denom / ( MC_CLOCKS_PER_BEAT * tempo * ns_in_tick.numer );
}

- (UInt64) start
{
	self.start_time = mach_absolute_time();
	current_clock = 0;
	
	return self.start_time;
}

- (UInt64) nextClock
{
	UInt64 t;
	
	current_clock += 1;
	t = _start_time + current_clock * ticks_in_clock;
	
	return t;
}

- (UInt64) ClockTicks
{
	return ticks_in_clock;
}

- (UInt64) BeatTicks
{
	return ticks_in_clock * MC_CLOCKS_PER_BEAT;
}

- (MIDIPacketList *) ClocksForDuration: (UInt32) ms
{
	// clock: 0xf8, start: 0xfa, stop: 0xfc
	Byte      clock[]  = { 0xf8 };

	// b/min ms ck/b min/s s/ms -> ck
	UInt32    clockPacketCount = ms * tempo * MC_CLOCKS_PER_BEAT / ( 60 * 1000 );
	UInt32    packetBufferSize = MC_PACKET_LIST_HEADER_SIZE + clockPacketCount * MC_CLOCK_PACKET_SIZE;
	
	UInt64 t = [self start];
	
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
