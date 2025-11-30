//
//  AppDelegate.m
//  MacMonium
//
//  Created by Pranav Gawai on 2025-10-20.
//

#import "AppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>

// Key mapping (same as your previous mapping)
const int kKeyToMidiNote[] = {
    ['z'] = 48, ['s'] = 49, ['x'] = 50, ['d'] = 51, ['c'] = 52, ['v'] = 53,
    ['g'] = 54, ['b'] = 55, ['h'] = 56, ['n'] = 57, ['j'] = 58, ['m'] = 59,
    [','] = 60, ['l'] = 61, ['.'] = 62
};

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Window
    NSRect frame = NSMakeRect(0, 0, 760, 420);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"MacMonium";
    [self.window center];

    // Content view
    NSView *contentView = self.window.contentView;
    contentView.wantsLayer = YES;

    // Background gradient - Soft blue-gray theme
    self.backgroundView = [[NSView alloc] initWithFrame:contentView.bounds];
    self.backgroundView.wantsLayer = YES;
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = self.backgroundView.bounds;
    grad.colors = @[(id)[NSColor colorWithCalibratedRed:0.94 green:0.96 blue:0.98 alpha:1].CGColor,
                    (id)[NSColor colorWithCalibratedRed:0.88 green:0.92 blue:0.96 alpha:1].CGColor];
    grad.startPoint = CGPointMake(0, 0);
    grad.endPoint = CGPointMake(1, 1);
    self.backgroundView.layer = grad;
    [contentView addSubview:self.backgroundView positioned:NSWindowBelow relativeTo:nil];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [self.backgroundView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        [self.backgroundView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.backgroundView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor]
    ]];

    // Title
    self.titleField = [self createLabel:@"MacMonium" size:28 bold:YES];
    [contentView addSubview:self.titleField];
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;

    // Angle / Air readout
    self.angleField = [self createLabel:@"Air: --%" size:14 bold:NO];
    [contentView addSubview:self.angleField];
    self.angleField.translatesAutoresizingMaskIntoConstraints = NO;

    // Scale selector
    self.scalePopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.scalePopUp.translatesAutoresizingMaskIntoConstraints = NO;
    self.scalePopUp.wantsLayer = YES;
    self.scalePopUp.bordered = YES;
    self.scalePopUp.layer.borderWidth = 1.5;
    self.scalePopUp.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.6].CGColor;
    self.scalePopUp.layer.cornerRadius = 4;
    [contentView addSubview:self.scalePopUp];

    // Tone selector
    self.tonePopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.tonePopUp.translatesAutoresizingMaskIntoConstraints = NO;
    self.tonePopUp.wantsLayer = YES;
    self.tonePopUp.bordered = YES;
    self.tonePopUp.layer.borderWidth = 1.5;
    self.tonePopUp.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.6].CGColor;
    self.tonePopUp.layer.cornerRadius = 4;
    [self.tonePopUp addItemsWithTitles:@[@"Warm", @"Bright", @"Vintage"]];
    [contentView addSubview:self.tonePopUp];

    // Naming pop-up
    self.namingPopUp = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.namingPopUp.translatesAutoresizingMaskIntoConstraints = NO;
    self.namingPopUp.wantsLayer = YES;
    self.namingPopUp.bordered = YES;
    self.namingPopUp.layer.borderWidth = 1.5;
    self.namingPopUp.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.6].CGColor;
    self.namingPopUp.layer.cornerRadius = 4;
    [self.namingPopUp addItemsWithTitles:@[@"Western", @"Sargam"]];
    [self.namingPopUp setTarget:self];
    [self.namingPopUp setAction:@selector(namingModeChanged:)];
    [contentView addSubview:self.namingPopUp];

    // Max air toggle
    self.maxAirSwitch = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.maxAirSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.maxAirSwitch.buttonType = NSSwitchButton;
    self.maxAirSwitch.title = @"Max Air";
    self.maxAirSwitch.wantsLayer = YES;
    [self.maxAirSwitch setTarget:self];
    [self.maxAirSwitch setAction:@selector(maxAirToggled:)];
    // Set black text color for Max Air switch
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSLeftTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSColor blackColor], NSForegroundColorAttributeName,
                                     [NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName,
                                     style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]
                                      initWithString:@"Max Air"
                                      attributes:attrsDictionary];
    [self.maxAirSwitch setAttributedTitle:attrString];
    [contentView addSubview:self.maxAirSwitch];

    // Air bar (progress) - wrapped in a container for border
    NSView *airBarContainer = [[NSView alloc] initWithFrame:NSZeroRect];
    airBarContainer.translatesAutoresizingMaskIntoConstraints = NO;
    airBarContainer.wantsLayer = YES;
    airBarContainer.layer.borderWidth = 1.5;
    airBarContainer.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.6].CGColor;
    airBarContainer.layer.cornerRadius = 5;
    [contentView addSubview:airBarContainer];
    
    self.airBar = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
    self.airBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.airBar.minValue = 0;
    self.airBar.maxValue = 100;
    self.airBar.doubleValue = 0;
    self.airBar.indeterminate = NO;
    self.airBar.controlSize = NSControlSizeRegular;
    self.airBar.style = NSProgressIndicatorStyleBar;
    [airBarContainer addSubview:self.airBar];

    // Legend (note names)
    self.legendField = [self createLabel:@"Loading..." size:12 bold:NO];
    self.legendField.translatesAutoresizingMaskIntoConstraints = NO;
    self.legendField.lineBreakMode = NSLineBreakByWordWrapping;
    self.legendField.maximumNumberOfLines = 4;
    [contentView addSubview:self.legendField];

    // KeyCaptureView (handles key events)
    self.keyView = [[KeyCaptureView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
    self.keyView.delegate = self;
    self.keyView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.keyView positioned:NSWindowAbove relativeTo:self.backgroundView];

    // Visual keyboard - White keys with dark borders
    self.keyButtons = [NSMutableArray array];
    NSArray<NSString *> *whiteKeyLabels = @[@"Z",@"X",@"C",@"V",@"B",@"N",@"M", @",", @"L", @"."];
    // We'll create 10 visual keys (positions)
    CGFloat keyWidth = 48;
    CGFloat keyHeight = 110;
    CGFloat startX = 40;
    CGFloat baseY = 120;
    for (int i = 0; i < whiteKeyLabels.count; i++) {
        NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(startX + i * (keyWidth + 8), baseY, keyWidth, keyHeight)];
        b.title = whiteKeyLabels[i];
        b.bezelStyle = NSBezelStyleRegularSquare;
        b.wantsLayer = YES;
        b.layer.cornerRadius = 6;
        b.layer.backgroundColor = [NSColor colorWithWhite:1.0 alpha:1.0].CGColor;
        b.layer.borderWidth = 2.5;
        b.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.7].CGColor;
        b.tag = i; // index
        b.enabled = NO; // purely visual, not clickable
        [contentView addSubview:b];
        b.translatesAutoresizingMaskIntoConstraints = NO;
        [self.keyButtons addObject:b];
    }

    // Layout constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.titleField.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:18],
        [self.titleField.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.angleField.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:10],
        [self.angleField.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        [self.scalePopUp.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:30],
        [self.scalePopUp.topAnchor constraintEqualToAnchor:self.angleField.bottomAnchor constant:18],

        [self.tonePopUp.leadingAnchor constraintEqualToAnchor:self.scalePopUp.trailingAnchor constant:16],
        [self.tonePopUp.centerYAnchor constraintEqualToAnchor:self.scalePopUp.centerYAnchor],

        [self.namingPopUp.leadingAnchor constraintEqualToAnchor:self.tonePopUp.trailingAnchor constant:16],
        [self.namingPopUp.centerYAnchor constraintEqualToAnchor:self.tonePopUp.centerYAnchor],

        [self.maxAirSwitch.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-30],
        [self.maxAirSwitch.centerYAnchor constraintEqualToAnchor:self.scalePopUp.centerYAnchor],

        [airBarContainer.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:30],
        [airBarContainer.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-30],
        [airBarContainer.topAnchor constraintEqualToAnchor:self.scalePopUp.bottomAnchor constant:18],
        [airBarContainer.heightAnchor constraintEqualToConstant:14],
        
        [self.airBar.leadingAnchor constraintEqualToAnchor:airBarContainer.leadingAnchor constant:2],
        [self.airBar.trailingAnchor constraintEqualToAnchor:airBarContainer.trailingAnchor constant:-2],
        [self.airBar.topAnchor constraintEqualToAnchor:airBarContainer.topAnchor constant:2],
        [self.airBar.bottomAnchor constraintEqualToAnchor:airBarContainer.bottomAnchor constant:-2],

        [self.legendField.topAnchor constraintEqualToAnchor:airBarContainer.bottomAnchor constant:12],
        [self.legendField.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:30],
        [self.legendField.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-30],

        // KeyView sits above everything clickable to capture key events
        [self.keyView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [self.keyView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        [self.keyView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.keyView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor]
    ]];

    // Initialize core components
    self.harmoniumEngine = [[HarmoniumAudioEngine alloc] init];
    [self.harmoniumEngine startEngine];

    self.lidSensor = [[LidAngleSensor alloc] init];

    // Scales mapping and keys
    [self setupScales];

    // Initial states
    self.lastLidAngle = -1.0;
    self.lastUpdateTime = CACurrentMediaTime();
    self.airPressure = 0.0;
    self.currentNamingMode = NoteNamingModeWestern;
    [self.namingPopUp selectItemAtIndex:0];

    // Set black text color for all popup buttons
    [self setBlackTextColorForPopUpButton:self.scalePopUp];
    [self setBlackTextColorForPopUpButton:self.tonePopUp];
    [self setBlackTextColorForPopUpButton:self.namingPopUp];

    // Initial legend
    [self updateLegend];

    // Timer for updates (50 Hz)
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(update) userInfo:nil repeats:YES];

    // Menu / About
    [self buildAboutMenu];

    // show
    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:self.keyView];
}

#pragma mark - UI helpers

- (NSTextField *)createLabel:(NSString *)text size:(CGFloat)size bold:(BOOL)bold {
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSZeroRect];
    label.stringValue = text;
    label.editable = NO;
    label.bordered = NO;
    label.drawsBackground = NO;
    label.alignment = NSTextAlignmentCenter;
    label.textColor = [NSColor colorWithCalibratedRed:0.2 green:0.3 blue:0.4 alpha:1.0];
    label.font = bold ? [NSFont boldSystemFontOfSize:size] : [NSFont systemFontOfSize:size];
    return label;
}

- (void)setBlackTextColorForPopUpButton:(NSPopUpButton *)popUpButton {
    NSArray *itemArray = [popUpButton itemArray];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSColor blackColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize:[NSFont systemFontSize]], NSFontAttributeName, nil];
    
    for (NSInteger i = 0; i < [itemArray count]; i++) {
        NSMenuItem *item = [itemArray objectAtIndex:i];
        NSAttributedString *as = [[NSAttributedString alloc]
                                  initWithString:[item title]
                                  attributes:attributes];
        [item setAttributedTitle:as];
    }
}

- (void)buildAboutMenu {
    NSMenu *main = [NSApp mainMenu];
    if (!main) {
        main = [[NSMenu alloc] initWithTitle:@"MainMenu"];
        [NSApp setMainMenu:main];
    }
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"MacMonium" action:NULL keyEquivalent:@""];
    NSMenu *appSub = [[NSMenu alloc] initWithTitle:@"MacMonium"];
    NSMenuItem *about = [[NSMenuItem alloc] initWithTitle:@"About MacMonium" action:@selector(showAbout:) keyEquivalent:@""];
    about.target = self;
    [appSub addItem:about];
    [appMenuItem setSubmenu:appSub];
    [main addItem:appMenuItem];
}

- (void)showAbout:(id)sender {
    NSAlert *a = [[NSAlert alloc] init];
    a.messageText = @"MacMonium";
    a.informativeText = @"MacMonium — a digital harmonium that uses your MacBook hinge as bellows.\n\nBuilt by Pranav Gawai. Inspired by LidAngleSensor by Sam Henrigold.";
    [a runModal];
}

#pragma mark - Scales and mapping

- (void)setupScales {
    self.availableScales = @[@"Chromatic", @"Major / Bilaval Thaat", @"Natural Minor", @"Kafi Thaat", @"Bhairavi Thaat", @"Minor Pentatonic"];
    self.scaleNoteMapping = @{
        @"Chromatic":             @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11],
        @"Major / Bilaval Thaat": @[@0, @2, @4, @5, @7, @9, @11],
        @"Natural Minor":         @[@0, @2, @3, @5, @7, @8, @10],
        @"Kafi Thaat":            @[@0, @2, @3, @5, @7, @9, @10],
        @"Bhairavi Thaat":        @[@0, @1, @3, @5, @7, @8, @10],
        @"Minor Pentatonic":      @[@0, @3, @5, @7, @10]
    };

    [self.scalePopUp addItemsWithTitles:self.availableScales];
    [self.scalePopUp setTarget:self];
    [self.scalePopUp setAction:@selector(scaleChanged:)];
    self.mappedKeys = @[@'z', @'s', @'x', @'d', @'c', @'v', @'g', @'b', @'h', @'n', @'j', @'m', @',', @'l', @'.'];
    self.currentNamingMode = NoteNamingModeWestern;
}

- (void)scaleChanged:(id)sender {
    [self updateLegend];
    // Reapply black text color after scale change
    [self setBlackTextColorForPopUpButton:self.scalePopUp];
}

- (void)namingModeChanged:(id)sender {
    self.currentNamingMode = (self.namingPopUp.indexOfSelectedItem == 1) ? NoteNamingModeSargam : NoteNamingModeWestern;
    [self updateLegend];
    // Reapply black text color after naming mode change
    [self setBlackTextColorForPopUpButton:self.namingPopUp];
}

- (void)maxAirToggled:(id)sender {
    // Nothing heavy here. The update loop reads the state.
}

#pragma mark - Key events from KeyCaptureView delegate

- (void)keyCaptureView:(KeyCaptureView *)view didReceiveKeyDown:(NSEvent *)event {
    if (event.isARepeat) return;

    NSString *s = event.charactersIgnoringModifiers.lowercaseString;
    if (s.length == 0) return;
    char ch = [s characterAtIndex:0];
    int midi = [self getMidiNoteForKey:ch];
    if (midi > 0) {
        [self.harmoniumEngine playNote:midi];
        [self highlightKeyForMidi:midi down:YES];
    }
}

- (void)keyCaptureView:(KeyCaptureView *)view didReceiveKeyUp:(NSEvent *)event {
    NSString *s = event.charactersIgnoringModifiers.lowercaseString;
    if (s.length == 0) return;
    char ch = [s characterAtIndex:0];
    int midi = [self getMidiNoteForKey:ch];
    if (midi > 0) {
        [self.harmoniumEngine releaseNote:midi];
        [self highlightKeyForMidi:midi down:NO];
    }
}

#pragma mark - Visual key handling

- (void)highlightKeyForMidi:(int)midi down:(BOOL)down {
    // find index of mappedKeys matching midi note (closest)
    for (int i = 0; i < self.mappedKeys.count && i < self.keyButtons.count; i++) {
        char keyChar = [self.mappedKeys[i] charValue];
        int mappedMidi = [self getMidiNoteForKey:keyChar];
        if (mappedMidi == midi) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSButton *b = self.keyButtons[i];
                if (down) {
                    b.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.3 green:0.7 blue:0.9 alpha:1].CGColor;
                    b.layer.borderColor = [NSColor colorWithCalibratedRed:0.2 green:0.5 blue:0.7 alpha:1].CGColor;
                } else {
                    b.layer.backgroundColor = [NSColor colorWithWhite:1.0 alpha:1.0].CGColor;
                    b.layer.borderColor = [NSColor colorWithCalibratedRed:0.3 green:0.4 blue:0.5 alpha:0.7].CGColor;
                }
            });
            break;
        }
    }
}

#pragma mark - Update loop

- (void)update {
    double currentTime = CACurrentMediaTime();

    // Read lid or fallback
    BOOL sensorAvailable = self.lidSensor.isAvailable;
    double angle = [self.lidSensor lidAngle];

    if (!sensorAvailable && self.maxAirSwitch.state == NSControlStateValueOff) {
        // sensor missing; show N/A and set air to 0
        dispatch_async(dispatch_get_main_queue(), ^{
            self.angleField.stringValue = @"Sensor: N/A";
            self.airBar.doubleValue = 0;
        });
        self.airPressure = 0.0;
        [self.harmoniumEngine updateVolume:(float)self.airPressure];
        self.lastUpdateTime = currentTime;
        return;
    }

    if (self.maxAirSwitch.state == NSControlStateValueOn) {
        self.airPressure = 1.0;
    } else {
        if (angle < 0) {
            // read error; do nothing
        } else {
            if (self.lastLidAngle < 0) {
                self.lastLidAngle = angle;
                self.lastUpdateTime = currentTime;
            } else {
                double dt = currentTime - self.lastUpdateTime;
                if (dt <= 0 || dt > 0.5) {
                    self.lastLidAngle = angle;
                    self.lastUpdateTime = currentTime;
                } else {
                    double instantVelocity = fabs(angle - self.lastLidAngle) / dt;
                    double pumpFactor = 0.012;
                    double smoothedVelocity = pow(instantVelocity, 0.85);
                    self.airPressure += smoothedVelocity * pumpFactor;
                    double decayRate = 0.45;
                    self.airPressure -= decayRate * dt;
                    if (self.airPressure < 0) self.airPressure = 0;
                    if (self.airPressure > 1) self.airPressure = 1;

                    self.lastLidAngle = angle;
                    self.lastUpdateTime = currentTime;
                }
            }
        }
    }

    // process fades in engine
    [self.harmoniumEngine processFadesWithDeltaTime:(currentTime - self.lastUpdateTime)];

    // Update audio engine volume
    [self.harmoniumEngine updateVolume:(float)self.airPressure];

    // Update UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.airBar.doubleValue = self.airPressure * 100.0;
        self.angleField.stringValue = [NSString stringWithFormat:@"Air: %.0f%%", self.airPressure * 100.0];
    });

    // keep lastUpdateTime reasonable
    if (self.maxAirSwitch.state == NSControlStateValueOff) {
        self.lastUpdateTime = currentTime;
    } else {
        self.lastUpdateTime = currentTime;
    }
}

#pragma mark - Legend+note mapping

- (void)updateLegend {
    NSMutableString *s = [NSMutableString stringWithString:@"Mapping: "];
    for (int i = 0; i < self.mappedKeys.count && i < 10; i++) {
        char ch = [self.mappedKeys[i] charValue];
        int midi = [self getMidiNoteForKey:ch];
        NSString *name = [self noteNameForMidi:midi];
        [s appendFormat:@"%c:%@  ", toupper(ch), name];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.legendField.stringValue = s;
    });
}

- (int)getMidiNoteForKey:(char)key {
    int base = kKeyToMidiNote[(int)key];
    if (base == 0) return -1;
    NSString *currentScale = self.scalePopUp.selectedItem.title;
    if ([currentScale isEqualToString:@"Chromatic"] || self.scaleNoteMapping[currentScale] == nil) {
        return base;
    } else {
        NSArray<NSNumber *> *intervals = self.scaleNoteMapping[currentScale];
        int root = 48; // C3
        int best = base;
        int minDist = INT_MAX;
        for (int oct = -1; oct <= 2; oct++) {
            for (NSNumber *iv in intervals) {
                int cand = root + iv.intValue + oct * 12;
                int dist = abs(cand - base);
                if (dist < minDist) {
                    minDist = dist;
                    best = cand;
                }
            }
        }
        return best;
    }
}

- (NSString *)noteNameForMidi:(int)midiNote {
    if (midiNote < 0) return @"-";
    if (self.currentNamingMode == NoteNamingModeSargam) {
        NSArray *sargam = @[@"Sa", @"re", @"Re", @"ga", @"Ga", @"Ma", @"MA", @"Pa", @"dha", @"Dha", @"ni", @"Ni"];
        int root = 48;
        int interval = (midiNote - root) % 12;
        if (interval < 0) interval += 12;
        NSString *name = sargam[interval];
        int oct = midiNote / 12;
        if (oct < 4) return [NSString stringWithFormat:@"%@̣", name];
        if (oct > 4) return [NSString stringWithFormat:@"%@̇", name];
        return name;
    } else {
        NSArray *names = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
        int octave = (midiNote / 12) - 1;
        NSString *n = names[midiNote % 12];
        return [NSString stringWithFormat:@"%@%d", n, octave];
    }
}

#pragma mark - Clean up

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.updateTimer invalidate];
    [self.harmoniumEngine stopEngine];
}

@end
