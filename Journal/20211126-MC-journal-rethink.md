<!-- 20211126-MC-journal.md -->

## 2021-11-26: Temporal video processing: row detection rethink

Previously, I discussed the importance of becoming familiar with the data I'm trying to process.  What I have been trying to do is systematize a way of detecting when each row of holes passes over the reader head, given the various complications noted previously.  And over the past couple of weeks, I've hit something of a block.

The other morning I had an insight - one which, as a software engineer, I should have seen much sooner.  I have been trying to do too much all at once.  I had assumed that I could detect rows of tape holes by looking at just frame-by-frame data.  But sometimes, the rows are not separated neatly along frame boundaries:  for any given frame, one column may be seeing data for one row of tape holes, while another column has data that is part of a preceding or following row.  This may occur, for example, when the tape is skewed passing over the reader bridge, or the camera angle is slightly perturbed from its ideal orientation in which each row is exactly aligned with one of the image axes.

So, if I can't apply row detection on a (video) frame-by-frame basis, what else can I do?  I could go back and redesign the reader device to give cleaner data (something I fully expect to do at some stage), but I still want to make the data decoding as robust as I can make it, so I'll push ahead with the imperfect video that I have.  

So, I need to devise a form of row detection that work across multiple frames.  My new insight is that I can apply a further step of data reduction before attempting row detection.  Instead of working with frame-by-frame feature centroids (where the "feature" here is a bright part of the image where a tape hole is passing over the illuminated slit), I have decided to combine these into "traces" that extend over multiple frames.  Then, my thinking goes, I can look for multiple traces that all have a start and an end, and substantially overlap in the frames where they appear.

I have implemented a "trace detection" algorithm, and a new visualization that shows recent traces edging there way across the image.  (The visualization looks a bit like the moving tape holes, but the movement shown is based on the passage of time, not the movement of the tape.  The width of a displayed feature is dependent on how long it remains visible.  Thus, if the tape moves more slowly, the displayed features are wider.)

As far as the reader hardware is concerned, there are some changes I want to make:

1. Make the camera mount more rigid, so it doesn't sway about as much when the tape is being drawn over the reader bar.
2. Increase the core diameter of the winder spools so there is less change in the overall diameter as tape accumulates on the take-up spool.
3. Implement some kind of winder gearing to make it easier to draw the tape at a steady slow speed.
4. Move the winder spools further from the reader bridge, so there is less opportunity for the tape to be skewed over the reader bridge.
5. I have contemplated trying to implement some kind of sprocket feed to more accurately guide the tape over the reader bar.

It may be worth emphasizing that all these changes have been prompted by working closely with the data, and building insights into its imperfections.


