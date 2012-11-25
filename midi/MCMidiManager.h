//
//  MCMidiManager.h
//  Mac Midi Tester
//
//  Created by Olivier Scherler on 25.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface MCMidiManager : NSObject

- (NSArray *) listDestinations;

@end
