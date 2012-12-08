//
//  MCTimeBase.h
//  iOS Midi Tester
//
//  Created by Olivier Scherler on 07.12.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <mach/mach_time.h>

#define MC_DEFAULT_TEMPO    120
#define MC_CLOCKS_PER_BEAT   24

@interface MCTimeBase : NSObject
{
	mach_timebase_info_data_t ns_in_tick;
	UInt64 ticks_in_clock;
}

@property (nonatomic, assign, setter = setTempo:) UInt32 tempo;
@property (assign) UInt64 start_time;

- (id) initWithTempo: (UInt32) new_tempo;

- (void) start;
- (UInt64) ClockTicks;
- (UInt64) BeatTicks;

@end
