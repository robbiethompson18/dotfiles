---
name: fake-final-report
description:
  Design an experiment by writing its final report first, with invented results, before anything
  runs. Use when Robbie runs /fake-final-report, asks for a fake or mock final report, or wants to
  "write the report first" for an experiment he is planning.
argument-hint: "[the experiment]"
---

# Fake Final Report

Write the report this experiment would end with, before running any of it. Having to draw the chart,
fill the table and write out one datapoint forces the decisions a plan leaves open: which dataset
and split, which conditions, which metric, what n, what gets saved per datapoint. Robbie corrects
the design by reading the fake, and only then does anything run.

Don't stop to ask about design choices. Pick, and list what you picked at the end: the fake report
is the question. Ask first only if you can't state what the experiment is asking.

## What is fake and what is real

- **Fake: every result.** Numbers, charts, model outputs, judge outputs, findings. Run no
  experiment: no model calls, no training, no evals, no pilot "to get a rough number".
- **Real: everything else.** Papers, datasets, splits, row counts, column names, model ids, file
  paths, prices. Look them up, never write them from memory. Reading a dataset card, downloading the
  dataset and counting what survives a filter is inspection, not an experiment, and is expected. If
  an input doesn't exist yet (a dataset the experiment will build), say so and say how it gets
  built.

Make the invented numbers ones you would bet on: plausible effect sizes against the prior work's
real numbers, noise, confidence intervals that match the n, and at least one real comparison that
comes out null or messy (a control that is null by construction doesn't count). A fake where
everything works teaches nothing about the design.

## Files

Follow the repo's conventions for write-ups and their images. Without any:

```
docs/<slug>-fake-report.md          the report
docs/<slug>-fake-report/
  plot.py                           holds the invented numbers, draws the charts, prints the table
  <chart>-fake.png
  rows/<datapoint id>/              one file per pipeline stage, see "Example rows"
    1-source-row.real.json
    3-model-output.fake.txt
```

Keep the invented numbers in one place, `plot.py`. Type in means and an assumed per-datapoint
spread, let it compute the intervals from the n, and paste the table it prints. Then the chart, the
table and the prose can't disagree. Scripts that produced a real part (counting rows after a filter,
rendering the prompt) stay in the directory too, taking any download path as an argument.

Mark the fake everywhere a future reader could meet it without context:

- "fake" in the name of the report, its directory and every file with invented content; `.real` on
  files that are not invented. If the repo indexes its docs, the index line starts with FAKE.
- The line under the title:
  `**Status (YYYY-MM-DD):** FAKE. Experiment design. Nothing has run; every number, chart and result row below is invented. The papers, datasets, row counts, model ids and prices are real.`
- "FAKE DATA" drawn across every chart, and a `"FAKE": true` field in every invented JSON row.

## The report

About 75 lines at the repo's wrap width, 100 at most, everything counted. If it runs over, the
experiment is too big for one report: cut conditions and arms before cutting setup detail, and say
what you cut.

Write it in the shape and voice of the real one, so that the real report is this file with the
numbers replaced. If the repo has earlier write-ups, copy their structure. Otherwise:

1. **Question.** One paragraph: what is being asked, and the one-sentence answer the fake results
   give.
2. **Prior work.** Two to four real papers, or earlier write-ups in this repo, each linked, with its
   publication year, the specific number or finding this experiment will be compared against, and
   what this experiment adds. A subagent's summary is not confirmation: open each link yourself and
   check the number before it goes in.
3. **Setup.** For every data source: its name, version and split, where it lives (Hugging Face id
   and commit, path or URL), how many rows it has, how many are used and each filter in between with
   the count it leaves. Then exact model ids, the conditions, the metric and how it is scored, the
   interval method, and the estimated cost and wall-clock time.
4. **Result.** At least one chart, embedded as `![alt](path)`, the one the real report would lead
   with: the same axes, conditions, error bars and n. Then a table with n and intervals, and two to
   four findings, each a bolded claim with its number. Use the repo's chart code and style if it has
   them, otherwise matplotlib and a static PNG.
5. **Example rows.** Follow one datapoint through the whole pipeline and link a file for each stage
   where data changes hands. Typically: the source row (real, verbatim for the fields the pipeline
   reads, with its id), the exact rendered model input, the model output, the scorer's or judge's
   input and output, and the final per-datapoint results row with every column the charts and tables
   are computed from. Skip stages this pipeline doesn't have. With several conditions per datapoint,
   write one input file per condition and one JSONL line per condition after that. Full text,
   nothing truncated. The rendered input means writing the real prompt template now; that is
   intended. Add a second datapoint where the first hides a case that matters (a failure, a refusal,
   a judge disagreement, a row the filter drops).
6. **Caveats.** The two or three ways the real result could differ from the fake, and what each
   would change about what gets done next.

The rows don't fit in the report, which is why it links them: one line per stage saying what the
file shows.

Sketch the design first (question, conditions, candidate datasets), then run the lookups as parallel
subagents: prior work, dataset inspection, model ids and prices. Have the dataset agent save raw
rows to disk and return paths, since a verbatim row doesn't survive a summary.

## When done

Don't start the experiment. Reply with the full path to the report and the design decisions you made
that Robbie didn't specify, most consequential first. Those are what he is here to correct.

When the real experiment finishes, its write-up replaces the fake: delete the fake report and its
directory in the same change.
