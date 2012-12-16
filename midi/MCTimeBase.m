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

// start the time base: record start time
- (void) start
{
	self.start_time = mach_absolute_time();
	current_clock = 0;
}

// stop the time base: reset start time
- (void) stop
{
	self.start_time = 0;
	current_clock = 0;
}

// check if time base is started
- (BOOL) isStarted
{
	return ( self.start_time != 0 );
}

// return time in ticks of current clock pulse
- (UInt64) clockTime
{
	return _start_time + current_clock * ticks_in_clock;
}

// schedule next clock pulse and return its time
- (UInt64) nextClock
{
	current_clock += 1;

	return [self clockTime];
}

// calculate how long before it’s time to send the next clock pulse
// assuming all the pulses were sent
- (UInt64) ticksToNextClock
{
	return [self clockTime] - mach_absolute_time();
}

// return number of ticks in a clock period
- (UInt64) clockTicks
{
	return ticks_in_clock;
}

- (double) ticksPerSecond
{
	return ticks_per_second;
}

// return number of ticks in a beat/quarter note
- (UInt64) beatTicks
{
	return ticks_in_clock * MC_CLOCKS_PER_BEAT;
}

// generate a packet list of clock pulses for the given duration
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
	
	UInt64 t = [self clockTime];
	
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
