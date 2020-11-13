# sccode

aj's Supercollider code repo

## Approach

- Instruments
- Effects
  - Each of these should be like a stomp box
	- FreeVerb
    - Random delay
    - Granular delay
- Loops
  - Each uses one or more instruments to play sounds
  - Use patterns to make them interesting and with some randomness
  - Use midi messages to switch from one loop to another
- Patches
  - Each patch is a combination of all the above.

Each instrument, effects, loop, and control object should be a class (and maybe a quark) so it can be re-used in more than one patch.

## Tasks

1. Build a simple reverb effect with:

    - A user interface to adjust parameters ~ Done!
    - midi control ~ Done!
    - Place all re-usable code into appropriate class defs ~ Done! 

1. Build a granulator stompbox from the demo

    - Sound code - Done!
    - Reuse classes from the simple reverb
	- Implement the MVC structure from the simple reverb
    - Build a UI
    - Midi control - Done!

1. Work out which code can be reused and create classes and a quark?

    - Class to create MVC views and controllers that go with a model. Done!
    - Class to generalize MIDI control? Done!

1. Decide if test-driven development is possible or helpful
1. Create modules for input/output and routing

    - Note that a mocking framework may not be necessary because you're not using anything external to SC, such as databases.
	- This doc has lots of techniques for testing in SC: [Comprehensive Guide to SuperCollider Unit Testing](https://gist.github.com/brianlheim/91222d487afa18582c287b0a722ae272)
	- Also see the UnitTest class: [UnitTest](http://doc.sccode.org/Classes/UnitTest.html)

1. etc...

## General Supercollider facts

I found that the package from the Ubuntu repos didn't include the emacs support. Instead follow the build and install notes here: 

[Installing SuperCollider from source on Ubuntu](https://github.com/supercollider/supercollider/wiki/Installing-SuperCollider-from-source-on-Ubuntu)

[Installing SuperCollider on Linux in 2019](https://lukaprincic.si/development-log/installing-supercollider-on-linux-in-2019)


