//
//  MCMidiMessage.h
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 20.05.13.
//  Copyright (c) 2013 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#import "MCMidiManager.h"

@interface MCMidiMessage : NSObject

@property (assign) MIDITimeStamp timeStamp;
@property (assign) kMIDIType status;

@end
