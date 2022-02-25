<!-- 20220225-MC-journal-rowdetect-redux-again.md -->


## 20220225: Row detection revisited again

Just as I was preparing to move ahead to extracting data from detected rows in the Monotype tape video, I noticed that the row detector I'd built wasn't performing very well over the length of the tape.  There were two apparent reasons for this (probably mentioned previously): (a) variations in the speed of the tape and, in particular, when the tape was moving in a jerky fashion such that some holes were visible for just one or two frames, and (b) the tape being skewed as it passed over the read head, so that not all holes in a row were exposed at the same time.

A simple engineering solution to this problem would be to just make a better quality video.  But I have been finding value in at least trying to work with the messy data I have, generating insights and motivations for visualizing the data that may or may not be useful in the longer run.  So I've revisited the row detection logic again.

I had already been thinking about using a variation of the RANSAC algorithm [1] to match tape holes to Monotype matrix coordinate data.  Now I decided that I needed to employ something similar for row detection.  Previously, I had been assuming that all holes in a row would be jointly visible at some instant.  The tape skew problem mentioned above meant that this isn't always true.

[1] https://en.wikipedia.org/wiki/Random_sample_consensus

I've decided that I need to look for groups of traces (most of which correspond to holes in the tape) that lie very close to a line.  This will involve finding a seed set and, if they sufficiently satisfy the straight-line criterion, look for additional traces (holes) that can be added to that set while closely maintaining that criterion.

The original algorithm would look for holes that are visible together and assume that they correspond to a row  of tape data.  Much of the time,  this  criterion works well, and (based on empirical observation of the data) it is very rare that at least some holes in a row fail to be visible together   So, rather than using random samples to create seed sets, which is what RANSAC does, I am choosing to look for seed sets of holes that are visible together.

To assess how well a set satisfies the straight-line criterion, I perform a simple linear regression [2] fit of a straight line through the values of the set, then calculate the mean of squared deviations of the values from the line.  The resulting value, called the _residual_, or _residual error_, is a measure of how closely the points meet the straight-line criterion.  

[2] https://en.wikipedia.org/wiki/Simple_linear_regression

Some empirical experimentation has been performed to determine an appropriate maximum value for the residual (error), and also to tweak the exact formula by which the residual is calculated.

Some further complications arise because there are multiple rows in the data, and it is sometimes possible that a particular hole might be matched with more than one row, while each hole in the tape must belong to exactly one row of data.  For example, _any_ pair of holes can be perfectly fitted to a straight line (i.e. with zero residual).  So some additional logic is used to allow several candidate rows to be considered, from which the "best" one is chosen.

Some additional work has been performed on the data visualization to help identify misallocation of traces holes) to rows while evaluating the evolving row-detection algorithm.  E.g., using different colours for unallocated traces and those assigned to alternating rows.

I also spent a few weeks exploring a computer algebra system [4,5] in search of a more direct way of assessing how closely a set of values matched the straight-line criterion.  Thus far, I have been unsuccessful and have resorted to a "brute force" approach to evaluating the residual, but it was an interesting diversion, and might prove a useful tool for working with, for example, some aspects of complex 3D desiogns.

[4] https://maxima.sourceforge.io/
[5] https://wxmaxima-developers.github.io/wxmaxima/



## Thinking about art and research

(This commentary motivated in part by my decision to "waste" several weeks exploring parameter estimation ideas and computer algebra systems as part of the activity described above.  Was it truly wasted?  I can't say at this time, but I feel I have some further process insights that might just prove useful later.)

It has struck me that there is some similarity between the process of creating an artwork and performing academic research.  Both are striving for some element of novelty, or uniqueness, in the result they produce.  This in turn requires some awareness of other related work - I have often noticed other artists asking "Have you seen the work by X?" when I offer a suggestion for how an idea might be developed and presented.  Yet the goals are different:  research (in science and engineering) generally aims to create new knowledge, where I would suggest that art is more aiming to create new forms of expression that connect people with ideas or concepts.  Research in humanities, as I perceive it, does a little of both.  Yet it seems to me that the process of exploring a space of ideas, doing experiments and seeing what they reveal, is similar in both (see also [3]).

[3] https://ora.ox.ac.uk/objects/uuid:8507e218-aa8f-4242-9fe8-9ef29ed69bf5

Compared with straight engineering, both art and research seem to value the process of exploration and discovery as much as the eventual published or exhibited result.  This in turn seems to affect the way that work is conducted, with greater interest exploring backwaters (and rabbit holes) along the way to some desired end goal.  (At least, when freed from resourcing constraints?)

@@ Implications:

- process?
- funding?
- dissemination?
- critical acceptance?
- public acceptance?
- sharing (open vs not)?






