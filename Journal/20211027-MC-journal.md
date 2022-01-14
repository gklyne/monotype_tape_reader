<!-- 20211027-MC-journal.md -->

## 2021-09-06: Building the tape reader

In the early days of discussing the Monotype Compositions project, I envisaged a workflow that would involve digitizing the Monotype Ribbon tape, and  using the resulting data to generate MIDI data as a way of experimenting with different ways of sonifying the data -- there are so many ways that sound could be generated, and I wanted to be able to experiment before committing to a physical mechanism for "playing" the tape.

This led me to thinking about what might be the easiest way overall for reading data from the tape.  A purely mechanical reading method was likely to require lot of mechanical design experimentation, something that could be time-consuming, and that I don't feel well equipped to undertake.  Similar considerations apply to an electro-mechanical reading approach (e.g. passing the tape over light sensors connected to a data-logging computer such as a Raspberry Pi).  As a software engineer, I sought to simplify the mechanical aspect as much as possible, and to do the difficult parts in software, on my "home ground" so to speak.

The approach I've adopted (at least initially) is to use a simple mechanical device to draw the tape over a slit light source, and video the result using a mobile phone.  Then I would transfer the video to a computer and use software to detect the paper tape holes as they pass over the light source, and write software using existing video processing libraries to extract the Monotype typesetting data represented by the tape.  This would still require some mechanical device to pass the tape over the light source, but the need any mechanical or electromechanical reader components would be avoided.  An initial design sketch was created quite quickly using OpenSCAD, a CAD tool that can be used to create shape descriptions for 3D printing.  Further progress would require a 3D printer to realize the designs.

Some time passed before I had access to a [Prusa 3D printer](https://www.prusa3d.com/product/original-prusa-i3-mk3s-3d-printer-3/).  After some initial experiments to familiarize myself with the printer and its associated software (which I found were a joy to use compared with the RepRap Mendel printer I had assembled over 10 years previously), I started to explore how to realize my outline designs.  Not being a skilled mechanical designer, It turned out that I needed several iterations to create a design that would work - many parts were tried in 4 or more design variations before settling on a construction that appeared to be usable.

The device itself is about as simple as I could imagine: a hand-cranked spool that would draw the Monotype Ribbon tape over a reader bridge with an embedded electroluminescent (EL) wire to provide illumination.  And a support arrangement to hold a mobile phone in the right place to record a video of the tape being drawn over the illumination.  Even designing such a simple device proved to be most useful as a way to refresh and improve my 3D object design skills (which yet remain quite rudimentary).

The design software I use, OpenSCAD, uses a textual representation of the designed parts that is rather like a programming language that described how to create the designed shape from a combination of simpler shapes.  It's a technique known as Constructive Solid Geometry, or CSG.  Because the shape definition is textual and has a well-defined structure, it would be easy to create these descriptions in software.  This led me to start thinking about possibilities for using the Monotype Ribbon data to control the creation of physical artifacts that might be played by some device, and the possibility of deepening public engagement through accepting offerings of data that can be used to create alternative objects that could be played by the "music box".  This could then use Claris Spratling's diary as a springboard to a much wider landscape of sonified text and other data.  These are just some vague ideas, and will need much more thought if they are to be pursued as the project evolves.


## 2021-10-11: Recording the video

At this point, I have a basic device that I can use to create a video recording of the Monotype Ribbon tape data.  The design always intended tom use software to compensate for any speed variations, but this would depend on having enough data recorded to be able to reliably detect each row of data.  

Making the recording turned out to be trickier than I expected.  To begin with, it was easy enough to turn the handle at a steady rate that would draw the tape slowly over the reader bar, with several video frames for each row of data.  But as the tape built on on the winder spool, it became harder to maintain a steady rate.  Also, the tape would start to wander from side to side, and snag on the winder spool rims and reader bridge guides, with attendant risk of damaging the tape.  Towards the end, I found myself drawing the tape over the bridge directly, expecting software to ignore the resulting pauses as I moved my hand to grasp the next length of tape.  But it was difficult to do this at a sufficiently slow speed, and some of the rows of data had very little data for reliable row detection.  

As I write this, I still don't know if I'll be able to fully analyze this early recording, but it provides a useful set of test data for testing analysis techniques.  I have since redesigned the winder spools and reader bridge to provide better control of the tape, and it does appear to be possible to wind the tape through from end to end.  I have yet to test this with a new recording.

A concern here is that the paper tape is not very strong, and might easily be damaged if it is not treated gently during the recording process.  It also leads me to think that a device to play the tape directly will need a much-improved mechanical design to avoid undue wear of the tape (of which we have just one copy of those used to print Clarice's diary).  This is one reason that I've been keen to use hand power to draw the tape, as a human operator can quickly detect any snagging of the tape and release the winding force before the tape is damaged.  The other reason is simplicity.  But it might be easier to achieve a slow, steady rate of tape advance using some form of powered drive.  

Considering a powered tape winding mechanism, my initial thought would be to use a stepper motor, but that would require a special controller and some software to provide the control signals.  I expect this would not be hard to achieve using a Raspberry Pi and off-the-shelf accessory hardware, but that would be an additional layer of complexity, and I'm keen to see if I can successfully extract data without taking this step.


## 2021-10-27: Processing the MT video

I've been using computer vision software libraries to extract data from a video recording of a Monotype Tape Ribbon being passed over an illuminated light source.  The idea is that by detecting the bright areas in the video as the tape is being drawn over the light, I will be able to detect and extract the Monotype Caster typesetting data.

Something that has been surprising to me is that the videos themselves have been seen by John as potential exhibits in their own right, where I have been seeing them primarily as a means to end.

In developing software to decode data from the video, I have also been generating some part-synthetic video that represents data from the decoding process:  the software is generating a "split-screen" video with the original video on the left hand side, and a synthesized video, representing data from the video processing pipeline, on the right hand side.  The initial purpose of this video is as a software debugging and monitoring tool, to help me see how well the software is doing at extracting information from the video.

Feedback from both John and Dawn has pointed out that the data patterns highlighted in patterns of the synthesized video have an aesthetic quality of their own, which, for example, is suggestive of rhythms that might be used when subsequently sonifying the typesetting data.

These comments have piqued my imagination about possibilities for presenting the video as an exhibit.  I have this idea of generating a display a little like The Matrix screen of "dripping" characters:  the detected highlights from the video might be moved along to match movement of the tape, yet changing in intensity and/or colour, becoming an alternative rendering that might, for example, be used as a "video backing display" for the sonified data.

Eventually the tools that I'm developing for debugging the video decoder might be repurposed as part of a final exhibition, maybe generating video as well as sound from a 3D printed rendering of the Monotype typesetting data.




