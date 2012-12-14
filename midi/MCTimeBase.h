//
//  MCTimeBase.h
//  iOS Midi Tester
//
//  Created by Olivier Scherler on 07.12.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <mach/mach_time.h>

#define MC_CLOCK_PACKET_SIZE        ( sizeof( MIDITimeStamp ) + sizeof( UInt16 ) + sizeof( Byte ) )
#define MC_PACKET_LIST_HEADER_SIZE  sizeof( UInt32 )

#define MC_DEFAULT_TEMPO      120
#define MC_CLOCKS_PER_BEAT     24

@interface MCTimeBase : NSObject
{
	double ticks_per_second;
	double ticks_in_clock;
	UInt32 current_clock;
}

@property (nonatomic, assign, setter = setTempo:) UInt32 tempo;
@property (assign) UInt64 start_time;

- (id) initWithTempo: (UInt32) new_tempo;
- (double) clocksPerSecondForTempo: (UInt32) new_tempo;

- (UInt64) start;
- (UInt64) nextClock;
- (UInt64) ClockTicks;
- (UInt64) BeatTicks;
- (MIDIPacketList *) ClocksForDuration: (UInt32) ms;

@end
