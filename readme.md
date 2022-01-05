# sccode

aj's Supercollider code repo

## Approach

- Signal controllers
  - Input stage
  - Ouput stage
  - Mixer??
- Instruments
  - Synths
  - Samplers
- Effects
  - Each of these should be like a stomp box
    - FreeVerb - Built
    - Random delay
    - Granular delay - Built
- Loops
  - Each uses one or more instruments to play sounds
  - Use patterns to make them interesting and with some randomness
  - Use midi messages to switch from one loop to another
- Patches
  - Each patch is a combination of all the above.
  - One patch per song.
  - Use buses to tie 'em together
  - patch includes patterns for instruments
  - midi pedal bindings for the loop
  - midi pedal bindings for the stomp boxes and instruments are saved with the patch!

Each instrument, effects, loop, and control object should be a class so it can be re-used in more than one patch.

## Tasks

1. Build a simple reverb effect with:

    - A user interface to adjust parameters ~ Done!
    - midi control ~ Done!
    - Place all re-usable code into appropriate class defs ~ Done!
    - Place the effect itself in a class so it can be reused in different patches. Done!

1. Build a granulator stompbox from the demo

    - Sound code - Done!
    - Reuse classes from the simple reverb - Done!
	- Implement the MVC structure from the simple reverb - Done!
    - Build a UI - Done!
    - Midi control - Done!
    - Place the effect itself in a class so it can be reused in different patches. Done!

1. Try a single patch with more than one stompbox. Done!
		Does the midi bit play nicely?

1. Implement full test suite and stick to TDD principles

    - Note that a mocking framework may not be necessary because you're not using anything external to SC, such as databases.
	- This doc has lots of techniques for testing in SC: [Comprehensive Guide to SuperCollider Unit Testing](https://gist.github.com/brianlheim/91222d487afa18582c287b0a722ae272)
	- Also see the UnitTest class: [UnitTest](http://doc.sccode.org/Classes/UnitTest.html)
	- Why, in TestMidiBinder, can I only run one test at a time without crashing the interpreter? This seems to be a problem with the Midi bit, because it doesn't affect the ViewMaker tests.

1. Create modules for input/output

	Input: Done!
	
	Output:
	- GUI
	- Output mono, but send it to both outputs
	- Mix inputs from multiple busses, e.g. hardware inputs, effects, and instruments
		Pass it a list of bus indexes, which is iterates over and adds a slider to a window for each one.

1. Build some reusable synth classes
   - Additive Polysynth. Done
   - Moog thing. Done
   - Fix filter in minimoog or build it separately?
   
1. Drums
   - [ ] More decent drum sounds
   - [ ] Work out how to sequence drums.

## General Supercollider facts

Installing from the Ubuntu packages for 20.04 worked perfectly and has a package for the emacs support.

[Installing SuperCollider from source on Ubuntu](https://github.com/supercollider/supercollider/wiki/Installing-SuperCollider-from-source-on-Ubuntu)

[Installing SuperCollider on Linux in 2019](https://lukaprincic.si/development-log/installing-supercollider-on-linux-in-2019)
