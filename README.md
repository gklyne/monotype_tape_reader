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

[ ] Redesign winder spools to use smaller shaft dia; 
    e.g. M4 using bolts rather than through-rod.
    This is to reduce friction when drawing the tape off the spool.

[ ] Design arms to hold tape tensioner(s)

[x] Slow down default tape speed (2.5ms -> 3ms between steps)

[ ] Consider progressive slowing of stepper motor as reading proceeds?

[ ] Check ordering of row data when multiple detected together

[ ] Add video frame number to output data file


## To consider


## Notes

Notes: 2023-02-25

Row 238, 2418, 3068 and others: still seeing markers between columns, but evaluating correctly

Row 3201 sprockets missed altogether?  Traces are there, but not used.

Row 3427 Detected hole out of range: y1   0.9962, d1   1.0432, n60 63, n30 31

Row 3631 sprocket trace missing

Row 3656 sprocket traces missing

Row 3932, and others, multiple double detection of column 5 hole - maybe merge regions/traces more aggressively?

4000 run on


Row 5085 - looks like genuine misread (missed row) due to lost sprockets or failed row detection?  Also, data is out order, with 3 rows detected in single frame.

Row 5087 - missing row is now detected!  Correctly!  
Frame number is with data, so order may need to be checked when writing file.

Row 78xx - rows crossed over

Row 802x - rows crossed over

Row 8284 - rows crossed over sprockets missed

Marker threshold setting is rather sensitive?


