# Your MacBook is Now a MacMonium

Hi, I'm Pranav Gawai (or **pranavgawaii** on GitHub). As a Computer Science student at MIT-ADT University, Pune, my MacBook is usually for compiling code, building projects, and managing placements. But I figured, why not make it musical?

This app transforms your MacBook into a surprisingly fun and expressive harmonium. You play the notes on the keyboard, and in a stroke of what is either genius or madness, you **use the laptop's lid as the bellows to pump air**.

This project is a fork and a complete musical reimagining of the original **LidAngleSensor** utility by the brilliant Sam Gold.

-----

## How to Play Your Laptop

The concept is simple, just like a real harmonium: you need air and you need to press a key.

  * **🎹 The Keys:** The bottom two rows of your keyboard are the keys (i.e., `Z`, `X`, `C`... for the white keys; and `S`, `D`, `G`...for the black keys). A handy legend in the app shows you exactly which note each key plays in the selected scale.
  * **💨 The Bellows:** This is the fun part. **Open and close your laptop lid to pump air**. The faster you move it, the more "air pressure" you build, and the louder the notes will be. If you stop pumping, the sound will naturally fade out as the air depletes.
  * **🎼 The Scales:** Not a fan of playing in Chromatic? Use the dropdown to switch between Major, Minor, and other scales to easily create melodies.

-----

## The Obligatory FAQ

**So, what is this, exactly?**
It's an app that proves that with enough programming, you can turn any piece of hardware into a musical instrument. It's also a creative exploration of macOS audio programming and hardware sensor integration.

**Wait, the LID is the bellows? How?**
Yep. MacBooks have a hidden lid angle sensor that reports its exact position. I'm using the *velocity* of the lid movement to simulate pumping air into a virtual reservoir. It's the most fun you can have with a hinge.

**Will it work on my M1/M2/M3 Mac?**
Tested on M1 Pro. Compatibility may vary on base M1 Air and 2020 touchbar Pro models.

**What about my iMac?**
Does it have a lid you can flap? No? Then you might be out of luck.

**Can I help?**
Please do! Fork the repo, add features, improve the audio mixing—go wild.
Right now, the code doesn't fully support piano-style sharper notes, so contributions in that area would be great!

**Why is the size so big?**
It's the 40 high-quality harmonium sound samples that make it authentic.

-----

## Origins & Big Thanks

This project stands on the shoulders of a giant. It would not exist without the original **LidAngleSensor** utility created by **Sam Gold**. He did the hard work of discovering the sensor and building the original app. I just put a musical spin on it. All credit for the foundational concept goes to him.

## Installation

Download the latest release from the [Releases](https://github.com/pranavgawaii/macmonium/releases) page.

## Building It Yourself

You'll need Xcode. Clone the repo, open the project, hit the big triangle play button, and you should be good to go.

