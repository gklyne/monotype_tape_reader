<!-- 20230924-more-reader-changes-needed.md -->

I met up with Dawn on a visit to Gravesend and Margate, with the intention of recording one or two videos of the Monotype tapes from typesetting Clarice's actual diary.  It didn't go smoothly, but we learned a few important lessons.


## Meeting in Gravesend 4th Portal

We had hoped to get a recording of the first of the diary tapes in St Andrews Chapel, Gravesend, then home of the 4th Portal.  The intention was that John (McK) could record this for posterity.  Unfortunately, we were distracted by other things happening in the chapel, and in the general confusion I forgot how to get the drive control software working, so in the end we didn't manage any recordings.  But I did eventually get the drive control software working, and added some notes to remind my future self what I need to do.

So Dawn and I agreed to meet up in Margate the next day and try again.


## Meeting in Margate

We spent some time getting the reader drive control software installed on Dawn's laptop, with the intention that I could leave the reader hardware with her to continue the recording process.  In the event, we weren't able to get a suitable recording, and some redesigns to the tape reader have been identified.

1. The drive belt that draws the tape through the reader was slipping, making it difficult to get a reasonably consistent speed of the tape across the read head.

2. The room environment in which we tried to record the tape was brighter than I had used previously.  We manually reduced the aperture when recording the video, but there was insufficient constrast to detect the tape holes.

3. Dawn's phone camera defaults to 4K @ 30fps.  Trying to process rthe video using OpenCV software proved to be extremely slow.


### Tape reader design

We need some way to tension the reader drive belt so that it doesn't slip.  Two possibilities come to mind:

(a) change the motor mounting to allow the motor to swing closer or further from the driven pulley, then locked in place, so that the position of the drive pulley can be adjusted.  This is similar to a common tensioning arrangement for automotive alternator drive belts.

(b) use a sprung or lockable follower pulley.  This would also allow the drive belt to be wrapped further around the driving and driven pulleys.

Also worth revisiting is to consider if the tape path friction can be further reduced.  Much of the friction now is from the tape path over the read head, so there may not be so much that is easily doable here.

Done ~2023-12.



### Video contrast for hole detection

Options here include:

(a) Use a darker ambient environment for recording the videos,

(b) See if the light source can be any brighter (I've just ordered some ostensibly brighter EL wire with a USB power supply - this may require the width of the reader bridge slot to be increased).  Done ~2023-12.

(c) Create an enclosure to shade the reader from ambient light.

@@@ TODO - test new EL wirer



### Video processing

I think lessons to be learned here are:

(a) Do not mess around with the video exposure, but rather allow the camera to set its own exposure level.  Focus instead in creating an environment that allows the camera to do its best.

(b) Stick to 1080P video resolution (or less):  the decoding process doesn't need, and cannot benefit from higher resolutions.  Faster frame rates may be helpful, as we do sometimes see tape rows missed because the gaps aren't sampled if the tape jerks forwards.





