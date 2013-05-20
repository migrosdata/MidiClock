//
//  MCMidiManager.h
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <mach/mach_time.h>

#import "MCTimeBase.h"

#define CLIENT_NAME    CFSTR("MIDICock Client")
#define IN_PORT_NAME   CFSTR("Input Port")
#define OUT_PORT_NAME  CFSTR("Output Port")

#define IAC_NAME @"IAC Driver Bus 1"

enum kMIDITypeEnum
{
	MS_NoteOff               = 0x80,
	MS_NoteOn                = 0x90,
	MS_AfterTouchPoly        = 0xA0,
	MS_ControlChange         = 0xB0,
	MS_ProgramChange         = 0xC0,   
	MS_AfterTouchChannel     = 0xD0,   
	MS_PitchBend             = 0xE0,   
	MS_SystemExclusive       = 0xF0,
	MS_TimeCodeQuarterFrame  = 0xF1,   
	MS_SongPosition          = 0xF2,   
	MS_SongSelect            = 0xF3,   
	MS_TuneRequest           = 0xF6,   
	MS_Clock                 = 0xF8,   
	MS_Start                 = 0xFA,   
	MS_Continue              = 0xFB,   
	MS_Stop                  = 0xFC,   
	MS_ActiveSensing         = 0xFE,   
	MS_SystemReset           = 0xFF,   
	MS_InvalidType           = 0x00    
};
typedef enum kMIDITypeEnum kMIDIType;

@interface MCMidiManager : NSObject

@property (assign) MIDIClientRef client;
@property (assign) MIDIPortRef inPort;
@property (assign) MIDIPortRef outPort;

@property (assign) MIDIEndpointRef iac;

- (kMIDIType) getTypeFromStatusByte: (Byte) inStatus;
- (void) parseMIDIPacketList: (MIDIPacketList *) list;
- (void) parseMIDIPacket: (MIDIPacket *) packet;

- (NSArray *) listDestinations;
- (void) sendTestPackets;
- (void) sendTestClockPackets;

NSString *getDisplayName( MIDIObjectRef object );

@end
