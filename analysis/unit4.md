# Unit 4: Viewing performance

In our case, the event is a viewing, the producer is a property, and the
actor is a renter. I used `duration_min` as the metric and the property's city 
as the region. A failure means a recorded `Renter no show`. Viewings with a
NULL reason are still counted, although this does not mean they succeeded.

## Task 4.1: Producer breakdown

The regional property operations manager would act on this breakdown.
Average duration hides how viewing lengths are spread out, and the count
hides which renters are counted repeatedly. Next, I would review individual
viewings, the duration distribution, repeat renters, and cancellation reasons.

## Task 4.2A: Conditional aggregation

| Volume question | Failure question |
|---|---|
| How many viewings did each property have? | How many were renter no-shows? |

I answered both questions in one query. Properties 2 and 3 account for five
of the 12 failures, or 41.67%.

## Task 4.2B: Subtotals and grand total

The regional director needs city subtotals to decide where to assign
follow-up work. The five `REGION SUBTOTAL` rows summarize the cities, while
the `PLATFORM GRAND TOTAL` row includes all 200 viewings and 12 failures.
The combined 6% rate lets leadership decide whether a response is needed
across the platform. The separate city rates do not directly give us that
overall rate.

## Task 4.2C: CTE pipeline

What is the failure rate across viewings at properties with at least
15 viewings? I first summarized each property in the CTE, then filtered
and combined those results. The eight qualifying properties have seven
failures in 145 viewings, giving a 4.83% comparison rate. This describes
that group; the rate for the whole platform is still 6%.

## Reflection

In our case, we need to know how many viewings each property had and how many of those viewings were renter no-shows. I used conditional aggregation to answer both questions in the same query. The count includes every viewing, while the CASE expression adds to the failure total only when the reason is 'Renter no show'. This allows us to keep the full event count without filtering out the records we need for the comparison.

Alternatively, we could run one query for all viewings and another filtered query for renter no-shows. The issue here is that we may be reading and grouping the same data twice. We would also need to match the property totals from the two results, including properties that had no failures.

With our 200 rows, the difference may be small. At a million rows, the additional reads and grouping can take more time and database resources, especially if the report runs frequently. I think keeping both calculations together is simpler to maintain as well. Although indexes could make a separate filtered query efficient, I would check the execution plan before assuming either approach is faster.
