<!--20230614-Journal-reader-and-software-improvements.md -->

It's been several months since my last journal entry.  Progress since then has been slow but reasonably steady. There have been numerous improvements to the tape reader hardware and software.

At this stage, I am regarding the reader and decoding software to be substantially complete, though there are still possible improvements that could be made.  In practice, I think the errors are few enough that they can be corrected by hand in the output data when discovered (the output file being a text file with frame numbers that can be cross-referenced with the video data, and which is easily modified using a text editor).  There is a separate "errors" file that indicates areas where possible inconsistencies have been detected, and which can be used in a manual review process.

The overall process of recording and decoding a tape can be rather sensitive to lighting conditions when the recording is made.  I have found that making the recordings at night in a room with low background light levels yields the best results, providing greater visual contract between the EL wire and the rest of the tape. I also need to avoid having light sources that may give rise to reflections from parts of the reader that are in view of the recording camera.


## Tape reader Mk3

A number of planned improvements to the tape reader hardware were identified in the last journal entry.  These have now all been implemented.  In summary, they are:

1. Use idler sprockets to guide the tape by its sprocket holes, reducing sliding contact with the edges of the tape and consequent tape damage.  

2. Longer tape spools, with more clearance of the tape width, so that the rims serve primarily to protect the tape, not to guide it.

3. Use a 3-spoked design for the tape spools to reduce the amount of plastic used in their manufacture, and also to make them lighter.

4. Include a small raised inner hub on the support brackets for the tape spools, reducing friction when drawing thye tape.

5. Shorten the tape path.  

6. Redesign the tape clips to slip on and off the winder spools.

A big additional change is to use a stepper motor rather than the hand-crank to draw tape over read head.  This allows for very much more even tape speed, and ultimately to maintain a more constant read speed by slowing down the motor as more tape is wound onto the take-up spool.  The motor is controlled by a Raspberry Pi with a stepper controller controller "hat", and a small custom program that provides signals to advance the motor at a desired rate.  The software is a command-line utility, run via an SSH remote terminal login to the Raspberry Pi, and provides a small number of simple interactive options for stopping, starting and varying the speed of the motor.  The software is in directory `winder-stepper-software` within the same GitHub repository as the 3D designs for the tape reader.  I'm currently using a Raspberry Pi 3, but the functionality can almost certainly be provided with a smaller (and cheaper) Raspberry Pi Zero.


Further changes to the design include:

1. Tape spool holder brackets redesign to also hold the stepper motor.  This avoids the drive belt tension causing the baseplate to flex and distort.

2. Tape spool redesign so that it can be easily separated to slide on a tape carrier/clip, and larger diameter to reduce proportional change in diameter as tape is wound on.

3. Add tape guide rollers that also help to maintain even tape tension and guide tape onto sprockets, and a push-on crank for rewinding tape (the fixed crank was creating uneven resistance when drawing tape over read head).

4. Redesigned clamp for holding a phone without fouling side-buttons (on an iPhone 11), and added extension plate so the camera holder vertical supports are further away from the tape path.

5. Various smaller design changes for more reliable printing, using less plastic, and easier assembly of the reader from its component parts.

An additional to the reader design is an alternate bridge, that clips into the same supports as the regular bridge, to help Dawn with manual decoding of Monotype tapes.  More details of all the changes can be seen in the [GitHub commit history](https://github.com/gklyne/monotype_tape_reader/commits/main).  


## Decoding software improvements

In parallel with the changes to the reader hardware, the video decoding software has been improved.  The most recent video of the introduction page was analyzed with just 8 inconsistencies detected, none of which led to discernable errors in the decoded data.

Details of the changes made can be found in the [GitHub commit history](https://github.com/gklyne/opencv-video-data-extraction/commits/main).

The key improvements made are through addition of sprocket hole tracking.  These changes were inspired by reflecting that when manually decoding data from the video, I would be using the row of sprocket holes as a guide to where the relevant data was to be found.  So, by tracking the sprocket holes separately, I aim to allow the software to be so guided, while still allowing for some spurious side-to-side and skewing movement of the tape, and especially variations in tape speed.  There is a potential sensitivity on initial detection of the sprocket holes (i.e. lacking data from previous frames), but in practice the tape lead-in with only sprocket holes, and relatively little "noise" in the initial frames, means this has not been a problem.  Subsequently, by excluding all trace data that lies clearly outside the tracked sprocket holes, several cases of spurious row data detected have been eliminated.

Other changes are improve trace detection, reduce spurious breaking up of traces due to missing, general tuning of various analysis parameters, and refactoring of the row detection logic.

Remaining problems include:

1. Occasional failure to detect "blank" -- i.e. rows with only sprocket holes.  This doesn't impact decoded typesetting data, but may affect the way we generate sound from the data.

2. Occasional failure to detect sprocket holes, though so far this hasn't resulted in any apparent errors in the decoded data.

3. Occasional multiple-detection of holes; this appears to be caused when the illuminated hole brightness is close to the hole detection threshold, or by an internal wire in the EL wire used appearing to split up the hole into multiple regions.

4. Missing data if the tape momentarily moves faster than the overall rate at which it is being drawn.  This is partly down to mechanical issues with the reader (e.g. the feed spool sticking).  Again, so far this hasn't resulted in any apparent errors in the decoded data.

5. A slight non-uniformity in hole spacing as they appear in the video image.  This may be due to an optical distortion effect in the video recording device, or slight inclination of the recording device relative to the tape.  I have given  some thought to enhancing the tape-tracking logic to use residual errors to estimate a correction for this, but so far this hasn't proven to be necessary.

Most of these errors may be fixed by further tuning of analysis parameters, though there may be other errors which haven't been picked up by internal consistency checks.


## Media player software

In fine tuning the video analysis process, I have found that examination of the synthesized visualization of the data analysis has been a very important tool.  A challenge has been that many commonly-available media players do not provide for backward single-frame stepping of the video.  Because the data analysis pipeline lags the actual video data, it is important to be able to step backwards from the point that a pipeline error is apparent to examine the corresponding video frames.  (I'm using a MacBook with an M1 processor for running the analysis, though the code itself should be portable to other systems.)

Researching this issue, I found a free media player [SMPlayer](https://en.wikipedia.org/wiki/SMPlayer) that does support backwards frame-stepping, which is what I routinely use when viewing the generated videos.

Another media player issue is that the code generates an AVI video file, which does not play reliably in Apple's Quicktime player (though SMPlayer is fine with it.  This file is also very large (I've been seeing about 7Gb for a 12 minute video); I think this is mainly because my software doesn't generate keyframes, hence the resulting video is relatively uncompressed.  In order to create a smaller file (about 1Gb) that works with Quicktime, I use Apple's Final Cut Pro to convert the video from AVI format to MP4 (`.m4v`), which I use for publishing the videos.



