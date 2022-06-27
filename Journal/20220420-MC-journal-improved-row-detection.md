# 20220420-MC-journal-improved-row-detection

## Improved row detection

After some time exploring the mathematics of direct calculation of a row-fitting residual (a statistical measure of how well a chosen set of markers correspond to a row), I gave up and went for a brute force approach; _viz_ to calculate the equation of the fit, then calculate the residuals.  This involves making two passes over the data, but in the event is not unreasonably expensive.

Moving on, the next step was to use this residual evaluation function in the identification and separation of data from different rows of the tape.  A variation of the RANSAC algorithm is used, in which multiple combinations of markers are selected and evaluated, and only those that meet minimum levels of conformance are considered as possible rows.  From these possibilities, the best matches are chosen.

A problem I encountered is that sometimes there are what appear to be "better" fits (in terms of the calculated residual) that actually cross over multiple rows of tape holes.  Statistically, given enough data, such anomalies are bound to occur from time to time, but they were happening more frequently than I considered acceptable for the task of decoding the tape data.  Yet, using the visualizations described previously, a human observer would immediately spot these errors.

Reflecting on this perception vs algorithm discrepancy, I came to a view that the human observer would also take note and avoid interpretations that allowed rows to cross over, or left potential matches unused.  That is, it would consider more than a single row in isolation.  A revision of the basic algorithm selects pairs of candidate rows and chooses based on the combined residuals.  This is a pretty crude way of extending the evaluation to consider multiple rows, but in practice did pretty well at eliminating many of the errors that were obvious to human observation:  at the time of writing, this is how the row detection is implemented.

This whole development has served to illuminate differences between human vision and object recognition, which operates in parallel and easily recognizes patterns in a larger context, and algorithmic recognition, which operates sequentially and is more easily conceptualized (by a programmer) as a series of sequential steps that reduce context and hence options from which matching patterns are selected.  

Visualization has continued to be a powerful tool for identifying and isolating cases where the row detection algorithm gets it wrong, yet largely avoiding the need for closer analysis in the majority of cases where the algorithm performs as desired.  This is an example of a technique combining computational speed and easy repeatability with the power of human perception.



