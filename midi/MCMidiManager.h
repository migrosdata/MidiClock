//
//  MCMidiManager.h
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#define CLIENT_NAME    CFSTR("MIDICock Client")
#define IN_PORT_NAME   CFSTR("Input Port")
#define OUT_PORT_NAME  CFSTR("Output Port")

@interface MCMidiManager : NSObject

@property (assign) MIDIClientRef client;
@property (assign) MIDIPortRef inPort;
@property (assign) MIDIPortRef outPort;

- (NSArray *) listDestinations;

NSString *getDisplayName( MIDIObjectRef object );

@end
