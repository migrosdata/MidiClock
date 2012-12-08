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

- (void) start
{
	self.start_time = mach_absolute_time();
}

- (UInt64) ClockTicks
{
	return ticks_in_clock;
}

- (UInt64) BeatTicks
{
	return ticks_in_clock * MC_CLOCKS_PER_BEAT;
}

@end
