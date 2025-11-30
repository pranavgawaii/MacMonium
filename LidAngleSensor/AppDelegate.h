//
//  AppDelegate.h
//  MacMonium
//
//  Created by Pranav Gawai on 2025-10-20.
//
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "LidAngleSensor.h"
#import "HarmoniumAudioEngine.h"
#import "KeyCaptureView.h"

typedef NS_ENUM(NSInteger, NoteNamingMode) {
    NoteNamingModeWestern = 0,
    NoteNamingModeSargam = 1
};

@interface AppDelegate : NSObject <NSApplicationDelegate, KeyCaptureViewDelegate>

@property (strong) NSWindow *window;

// Core systems
@property (strong) LidAngleSensor *lidSensor;
@property (strong) HarmoniumAudioEngine *harmoniumEngine;

// Timing & physics
@property (nonatomic, assign) double lastLidAngle;
@property (nonatomic, assign) double lastUpdateTime;
@property (nonatomic, assign) double airPressure;

// UI
@property (strong) KeyCaptureView *keyView;
@property (strong) NSView *backgroundView;
@property (strong) NSTextField *titleField;
@property (strong) NSTextField *angleField;
@property (strong) NSPopUpButton *scalePopUp;
@property (strong) NSPopUpButton *tonePopUp;
@property (strong) NSPopUpButton *namingPopUp;
@property (strong) NSButton *maxAirSwitch;
@property (strong) NSProgressIndicator *airBar;
@property (strong) NSTextField *legendField;
@property (strong) NSMutableArray<NSButton *> *keyButtons; // visual keys

@property (strong) NSTimer *updateTimer;
@property (nonatomic, assign) NoteNamingMode currentNamingMode;
@property (strong) NSArray<NSString *> *availableScales;
@property (strong) NSDictionary<NSString *, NSArray<NSNumber *> *> *scaleNoteMapping;
@property (strong) NSArray<NSNumber *> *mappedKeys; // keys in order

// Mapping table (C3 = MIDI 48)
extern const int kKeyToMidiNote[];

- (int)getMidiNoteForKey:(char)key;
- (NSString *)noteNameForMidi:(int)midiNote;
- (void)updateLegend;
- (void)playVisualForMidi:(int)midiNote;

@end
