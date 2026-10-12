# Unit 3 Finding: Interrogating the Data

**To:** Dashboard Team

**From:** Trust and Data Team

**Subject:** Rental viewing no-show report and frozen agent commissions

The dashboard reported that about half of all property viewings ended in a
renter no-show. The complete dataset does not support that conclusion. It
contains 200 viewings, and only 12 are recorded as renter no-shows. The actual
no-show rate is 6%, while the other 188 viewings are not recorded as renter
no-shows. This difference is large enough to change the decision made from the
dashboard.

The reported rate was inflated because 166 viewings had no reason recorded and
were silently left out of one comparison. The dashboard effectively compared
the 12 renter no-shows with only 22 viewings that had a different recorded
reason, making the result appear close to half. The corrected comparison counts
188 viewings as not being renter no-shows. The audit also found a second problem
in a related report: it attempted to filter on a calculated day-of-week label
before that label was available. After correcting the order, both versions of
the day-of-week report returned the same 21 viewings.

The agent commission freeze should be lifted because the data used to justify
it was incomplete and the corrected 6% rate does not support the dashboard's
claim. The dashboard should be updated to include every viewing in its rate,
show the event count beside the percentage, and confirm that the counts total
200 before it is used for another payout decision.
