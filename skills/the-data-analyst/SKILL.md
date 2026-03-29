---
name: the-data-analyst
description: Analyze datasets and generate insight reports with visualizations. Use when the user says "데이터 분석해줘", "analyze this data", "리포트 만들어줘", "visualize this", or provides CSV/JSON data for analysis. Produces structured markdown reports with chart recommendations.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "데이터 분석해줘"
  - "analyze this CSV"
  - "리포트 만들어줘"
  - "visualize this data"
---

# The Data Analyst

Structured data analysis: load → explore → visualize → report.

## Use This Skill When

- The user provides data (CSV, JSON, API response) for analysis.
- The user says "데이터 분석", "analyze this", "리포트 만들어".
- The user wants insights, trends, or anomalies from a dataset.

## Do Not Use This Skill When

- The user wants a database query (just write the query).
- The data is code, not datasets (use the-code-reviewer or the-codebase-mapper).

## Workflow

### Step 1 — Load & Profile

1. Read the data source (CSV, JSON, database export, API response).
2. Profile the dataset:

```
## Data Profile
- **Source**: {file/API/database}
- **Records**: {row count}
- **Columns**: {column count}
- **Date range**: {if time-series}

### Schema
| Column | Type | Non-null % | Unique values | Sample |
|---|---|---|---|---|
| {name} | {type} | {%} | {count} | {example} |
```

### Step 2 — Exploratory Analysis

Compute summary statistics and identify patterns:

```
## Summary Statistics
| Metric | {col1} | {col2} | {col3} |
|---|---|---|---|
| Mean | {val} | {val} | {val} |
| Median | {val} | {val} | {val} |
| Std Dev | {val} | {val} | {val} |
| Min | {val} | {val} | {val} |
| Max | {val} | {val} | {val} |

## Distributions
- {column}: {normal/skewed/bimodal/uniform} — {key observation}

## Correlations
- {col1} ↔ {col2}: {strong positive/negative/none} ({r value})

## Anomalies
- {row/range}: {description of anomaly and potential cause}
```

### Step 3 — Visualizations

Recommend and generate chart specifications:

```
## Recommended Charts

### Chart 1: {title}
- **Type**: {bar/line/scatter/heatmap/pie}
- **X axis**: {column}
- **Y axis**: {column}
- **Purpose**: {what insight it shows}
- **Library**: Recharts / ECharts

### Chart 2: {title}
...
```

If the user wants actual chart components, generate React + Recharts code:
```tsx
import { BarChart, Bar, XAxis, YAxis, Tooltip } from 'recharts';

const data = [ /* processed data */ ];

export function MetricChart() {
  return (
    <BarChart data={data} width={600} height={300}>
      <XAxis dataKey="name" />
      <YAxis />
      <Tooltip />
      <Bar dataKey="value" fill="#8884d8" />
    </BarChart>
  );
}
```

### Step 4 — Insights & Report

```
## Analysis Report: {title}

### Key Findings
1. **{finding}**: {evidence and implication}
2. **{finding}**: {evidence and implication}
3. **{finding}**: {evidence and implication}

### Trends
- {trend description with supporting data points}

### Recommendations
- {actionable recommendation based on findings}

### Methodology
- Data source: {source}
- Analysis period: {date range}
- Tools used: {Python/pandas, SQL, manual computation}
- Limitations: {data quality issues, missing data, caveats}
```

## For Python Analysis

When deeper analysis is needed:
```python
import pandas as pd

df = pd.read_csv('data.csv')
summary = df.describe()
correlations = df.corr()
```

Use Python when:
- Dataset is large (> 1000 rows)
- Complex statistical analysis needed
- Time-series decomposition
- Groupby aggregations

## Done Definition

The analysis is complete when:
- Data is profiled (schema, types, completeness).
- Summary statistics are computed.
- At least 2 key findings are identified with evidence.
- Visualization recommendations are provided.
- Report is structured and actionable.
