# Eval 19: Data Analysis Report

## Objective

Test the agent's ability to analyze a dataset and produce a structured insight report.

## Prompt

> Analyze this CSV dataset and produce a report with key findings, trends, and visualization recommendations.

## Setup

- A CSV file with 100-500 rows and 5-10 columns.
- The dataset should contain: at least one time-series column, one categorical column, and identifiable patterns/anomalies.

## Expected Behavior

1. Agent profiles the dataset (schema, types, completeness).
2. Agent computes summary statistics.
3. Agent identifies at least 2 key findings with evidence.
4. Agent recommends appropriate chart types with specifications.
5. Agent produces a structured markdown report.

## Scoring

- **pass**: Data profiled, statistics computed, findings evidence-based, chart recommendations appropriate, report structured.
- **partial**: Report produced but findings lack evidence or chart recommendations are generic.
- **no**: No data profiling, or findings are speculative without evidence.

## Rubric Dimensions

- Data profiling accuracy (types, completeness, schema)
- Statistical analysis correctness (means, distributions, correlations)
- Finding quality (evidence-based, actionable)
- Visualization appropriateness (chart type matches data shape)
- Report structure (clear sections, methodology noted)
