# MacMonium

A lightweight macOS app that turns your MacBook into a digital harmonium. Pump the “bellows” by moving the laptop lid, play notes on your keyboard, and shape the tone — all in a clean, responsive UI.

## Highlights
- Uses the MacBook’s internal lid angle sensor as bellows (air pressure)
- Play via the computer keyboard (Z X C V B N M , L .)
- Scale selection (Chromatic, Major/Bilaval, Natural Minor, Kafi, Bhairavi, Minor Pentatonic)
- Two note-naming modes: Western (C4, D#4) and Sargam (Sa, Re, ...)
- Adjustable tone presets (Warm, Bright, Vintage)
- Visual keyboard highlights pressed notes
- Smooth fades and volume tied to air pressure

## How it works
- The app reads the lid angle and converts motion into air pressure.
- Air pressure controls overall volume and fades.
- Your Mac keyboard triggers notes (mapped to MIDI around C3/C4).
- The legend shows the current mapping with either Western or Sargam names.

## Controls
- Max Air: Force full bellows pressure (useful if the sensor isn’t available).
- Scale: Constrains keypresses to the chosen scale (Chromatic passes everything).
- Tone: Selects a simple timbral preset.
- Naming: Switch between Western and Sargam note display.

Keyboard mapping (visual keys shown in the UI):
