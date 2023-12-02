# monotype_tape_reader

Mechanical parts for reading paper tape created by Monotype keyboard.


## TODO

### 2021-09-27: Revisions to first prototype

- [x] Stiffen camera support area of baseplate so it doesn't flex with weight of phone.  Propose to extend plate both sides of reader bar.

- [x] Camera support bracket:  make space for nuts on the threaded rod (move holes away from vertical side)

- [x] Camera support bracket: increase width of base.

- [x] positive location/keying for reader bar.

- [x] Increase M4 hole size

- [x] Arrangement to prevent phone holder rotating on bar.  Also improve phone positioning.

- [x] Countersink for winder crank screw; review crank design to ensure pulley groove is clear of turning crank

- [x] Option to remove winder so that tape can be loaded/unloaded.

- [x] tape tensioning arrangement.  Guides to wrap tape around reader bar?

- [x] slot in winder shaft for catching tape (?)  C-clip over shaft?

- [x] Clamp to attach reader mechanism to a solid baseplate.

- [x] Larger gaps and guide rods for reader bar


### 2022-08-19: revisions to Mk2

(see Journal/20220819-MC-journal-reader-mk2.md)

[x] Redesign the tape-path guides to use guide sprockets.

[x] Include a small raised inner hub on the support brackets for the tape spools.

[x] Make the tape spools wider (more excess over width of the tape)

[x] Use a spoked design for the tape spools (less plastic, print time and weight).

[x] Replace axle for tape spools with a plastic locking arrangement, so they are more easily separated to remove the tape.

[x] Redesign the tape clips to slip on and off the winder spools, and with a lip to stop them spinning


### 2022-10-02: revisions to Mk2.5

[x] Clip wider flange

[x] Storage clip more clearance, no break.  This to allow it to slide off.

[-] Stiffer baseplate (8 -> 12mm edge height?) (doesn't seem necessary?)

[x] Additional mount and foot for winder/stepper (front edge)

[x] Winder separate from reader bridge (drive belt stresses structure)

[x] Captive nut holders in baseplate (shortened overall length by 100cm)

[-] Make the baseplate wider (doesn't seem necessary?)

[x] Sprocket pins larger (why are they so small?)


### 2022-12-10: using stepper motor to driver spool

[x] Code options for stop, start, speed?

[x] Stiffen up stepper motor bracket and spool support

[x] Single piece side support and stepper bracket

[x] Larger stepper pulley for drive

[x] Sprocket guides wrap further around sprockets


### 2023-02-03: tweak design

[x] smaller stepper motor pulley (50mm -> 35mm) - should be less liable to stalling motor

[x] wider flanges on tape guide rollers, reduced tape width clearance - hopefully reducing tendency of tape to ride up on rollers.

[x] adjust to use nylock nuts for axle supports, to prevent the axles from tightening on the supports while processing a tape.

[x] increase height of guide sprocket pins, to try and reduce tendency for the tape to ride off the pins

[x] redesign spool clip


## 2023-02-16: reasonably successful recording (?)

[x] Try spool clip without support bridges

[x] Drive belt channel should be wider, U-profile.

[x] Balance feeder spool (handle makes it unbalanced)

[x] Shim for spool end, for more positive "click"


## 2023-02-20:

[x] Smaller stepper motor pulley

[x] Reader bridge add shades to reduce detection of outer EL wire

[x] Use dark colour plastic for reader bridge

[x] Redesign winder spools to use smaller shaft dia; 
    e.g. M4 using bolts rather than through-rod.
    This is to reduce friction when drawing the tape off the spool.

[x] Design arms to hold tape tensioner(s)

[x] Slow down default tape speed (2.5ms -> 3ms between steps)

[x] Check ordering of row data when multiple detected together

[x] Add video frame number to output data file


## 2023-02-20:

[x] Progressive slowing of stepper motor as reading proceeds.


## 2023-09-24:

Following [meeting with Dawn](Journal/20230924-more-reader-changes-needed.md).

[x] Wider slot for brighter EL wire (+0.2mm)

[x] Wider light baffles on EL bridge

[x] Drive belt tensioning arrangement

[x] More flexibility of camera positioning

[ ] Make camera clamp screws easier to access

[ ] Mount for Pi Zero and EL switch wire (and power supplies?)


## 2023-11-25

[x] Winder side clip not closed

[x] Hinge on motor mount is too close

[x] Extend curved slot towards motor body

[x] Extend tension adjustment link by 2-3mm

[x] Shorten & widen tension adjustment clamp/nut holder

[x] Reduce size of screw bulge on motor holder (radius by 1mm?)

[x] Wider spacer ridge on inside of winder holder side

[x] Extend arm on winder holder side; shorten adjustment link.
    - still need to choose adjustment arm length
    - is this a good idea? Single link may be more rigid

[x] Adjuster link countersink one end only.  Other end uses cap head.

[x] Lower baffle (shade) on reader bridge

[ ] Winder spool axis: use bearing or sleeving to avoid creep along the shaft thread
    - use spool design from free end, and add sleeves over M4 screw.
    - New clip holes need to be diameter of sleeve.
    - Use sleeve bearings on both spools to reduce drag.

[ ] Shorter roller arm on take-up spool side?



## To consider

[ ] Marker threshold setting is rather sensitive

[ ] Running calibration of data scale - maybe it's not truly linear (consistent hole 22 deviation).
    Consider low order polynomial, correction (quadratic?, cubic?)


## Notes

### Notes: 2023-03-05


## Write-up notes

### Pipeline

Iterating the design

Aim to use software as much as possible, while keeping the hardware simple

Design involving iterative updates to both hardware and software

Initially: reader and video analysis

Then switch to 3 elements: hardware, stepper control s/w, video analysis

Basic mechanism and analysis worked fairly easily, but...

Dealing with noisy data, interactions between:
- better video analysis
- better hardware
- better tape motion control

Lots of learning:  more efficient use of openSCAD for evolving mechanical design; OpenCV for video analysis and generation, Raspberry Pi to control stepper motor, simple statistics-based algorithms for dealing with noisy data.

Each attempt to improve the decoding software can show up fundamental problems with the raw data, which are not reliably overcome by better processing (e.g. might confuse a human attempting to decode the data), thus giving rise to new hardware iterations.  Then each new hardware iteration and video recording can throw up new patterns of data noise to be handled by the decoding software, so there's a lot of iteration between hardware and software improvements.

Ambient lighting is a big factor in the quality of video obtained.


### Reader hardware

Initially simple hand crank from  spool to spool, drawing tape over EL wire

Tape guide hardware enhancements to reduce tape wear

Hardware enhancements to use less plastic when printing

Using code to describe hardware (CSG, OpenSCAD)

Building a component library (OpenSCAD)

Increase spool size to reduce tape speed variation beginning to end (pre-stepper)

Switched to stepper motor drive for better control of tape speed

Additional hardware (rPI, stepper controller, stepper motor) and software to control stepper

Added speed profile (to control software) as analysis had holes merging towards end of tape

Add tape follower rollers to help keep tape on guide sprockets, and absorb some slack

Add rod mounting plate extensions to leave for space for tape follower roller arms


### Decoding software

Processing pipeline

Uses OpenCV to read recorded video, and to perform initial threshold detection

Initial processing draws inspiration from motion capture software implemented in 1980s

Pipeline applies conversion from (X,Y) coordinates in video to (Y,frame) coordinates for data decode.

Row detection uses RANSAC-inspired algorithm to identify row-aligned markers.

Also uses OpenCV to create synthesized video of analysis process, with original video and internal data from processing pipeline.

Data visualization has proved very important whole developing algorithm, especially for understanding the impact of noisy data and helping to identify algorithmic improvements.  Also helped to identify where hardware improvements were needed.

Have spent significant thought reflecting on how I, as a human observer, am easily seeing row data where the algorithm if failing.  This has led to changes in the structure of the pipeline; e.g. noticing that the sprocket holes are a very regular pattern, and introducing in-pipeline feedback to use detected sprocket holes to help discard spurious data in the earlier row-detection phase.



