<!-- 20220819-MC-journal-reader-mk2.md -->

It's been a slow time since the last journal entry, during which I've 

1. prepared and presented a poster about our work to date at the Oxford Digital Humanities Summer School, and 

2. worked on a revised design for the tape reader, attempting tom overcome some problems with the previous design.

The poster can be seen at [20220516-DHOxSS-Monotype-Reader-poster.pdf](../Notes/20220516-DHOxSS-Monotype-Reader-poster.pdf), and describes in very broad terms the work to date to extract data from the Monotytpe tape. 


## Monotype reader Mk2

A number of problems were noted with the original Monotype tape reader design:

1. Tape movement would become stiffer as take-up spool filled up and caused the tape to become more difficult to draw smoothly over the read head.  This in turn meant that video quality towards the end of the tape became poorer, and data could not be decoded effectively.  (When the tape moves more quickly over the read head, fewer video frames mean that holes in successive tape rows can be missed out or merged, resulting in loss of data when the video is analyzed).

2. The phone camera support was rather flexible, which resulted in undue camera movement and reduced video quality, particularly as the take-up spool became fuller (see above).

3. Tape skew as it passed between the spools meant that it would be forced against the guide rim of the read head or take-up spool, potentially causing damage to the tape.

Changes were made to the tape reader design to reduce these problems:

- The baseplate was extended in an attempt to reduce tape skew and hopefully reduce pressure from the guide rims on the paper tape.

- Additional bracing structures have been designed into the base plate to make the camera mount stiffer.

- The take-up spool core diameter has been increased to reduce the proportional variation in diameter as tape is wound onto the spool.

- A speed reduction between the winder crank and the take-up spool has been implemented by way of a pulley drive from the crank to the spool, to compensate for the larger spool core, slowing down the speed at which tape is drawn over the read head for a given rate of turning the crank.


These changes were only partially successful:

While the tape skew may have been reduced, this did not help the problem of tape being forced against the guide rim of the take-up spool; if anything, the resulting design is more prone than the original to damage the tape, and the problem of guiding the tape needs to be re-thought.

The extended baseplate has also meant that the available length of tape leader is not enough to reliably catch under the clips used to hold them on the winder spool cores -- until there is enough tape wound around the core, the core just slips and the tape is not drawn across the reader head.

The stiffened camera mount seems to be working OK, particularly when the baseplate is clamped to a stable service when operating the reader.

It's too soon to tell for sure, but the winder crank speed reduction seems to be working OK.  Originally I tried using rubber bands for the reduction-drive belt, but these proved too stretchy and it was difficult to maintain a steady tape speed over the read head.  So I changed to using a PU (polyurethane?) belt material which can be "welded" to a desired length, which seems to be working reasonably well.  (I have been trying to ensure that the drive belt will slip if there is undue force needed to turn the take-up spool, in an attempt to reduce the likelihood of tape damage if something should jam.)

If it turns out that the hand-winding is still a problem for maintaining a steady tape speed, I'm ready to start thinking about using a stepper motor to draw the tape.  This would incur considerable additional effort to include electronics and/or software to drive the motor, but should make it much easier to maintain a steady speed.  One of my original concerns with using a motor drive was that the force applied to the tape might be higher than desirable, but this would be less of a concern if using a pulley-and-belt drive system.  This change, if implemented, will be for a subsequent version of the tape reader.


## Monotype reader Mk3

This leads me to consider a number of changes to be made for a 3rd version of the tape reader.

1. The main change will be to re-think the tape-path guides.  So far, I have attempted to use static rims that guide the edge of the tape.  But when the tape is being drawn under some tension, it can be forced against the rims causing the edge of the tape to be scuffed and potentially damaged.  My next thought is to use idler sprockets to guide the tape by its sprocket holes, eliminating sliding contact with the edges of the tape.  These guide sprockets will replace the bars that currently guide the tape over the read head, and should also reduce drag in the tape path, thereby reducing the force needed to draw the tape.

2. The tape spools can be made longer (wider than the tape) so that the rims serve primarily to protect the tape, not to guide it.  Ideally, the edges of the tape will never touch the spool rims as the tape is drawn through the reader:  I'm hoping the guide sprockets will ensure this is the case.  At the same time, make the baseplate wider, allowing more end-float for the winder spools.

3. Use a 3-spoked design for the tape spools to reduce the amount of plastic used in their manufacture, and also to make them lighter.

4. Include a small raised edge on the support brackets for the tape spools, to avoid the spool rims rubbing against the brackets and thereby causing drag.

5. Shorten the tape path.  The original baseplate design could be 3D-printed as a single piece on the Prusa printer.  The Mk2 design has to be printed as two separate pieces that are held in position by the support brackets for the read head.

6. Redesign the tape clips to slip on and off the winder spools, and revise the design (maybe with a mating bump and recess?) so that they do not slip around the spool cores.



\