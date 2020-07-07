# sccode

aj's Supercollider code repo

## Approach

- Instruments
  - Each of these should probably be like a preset of a synth. More like an instrument in the traditional sense
- Effects
  - Each of these should be like a stomp box
    - Random delay
    - Granular delay
- Loops
  - Each uses one or more instruments to play sounds
  - Use midi messages to switch from one loop to another
- Control objects
  - Objects to send midi message to the right instrument, effect, or loop
- Patches
  - Each patch is a combination of all the above.

Each instrument, effects, loop, and control object should be a class so it can be re-used in more than one patch.

## Tasks

1. Build a simple reverb effect with:
  - A user interface to adjust parameters
  - midi control