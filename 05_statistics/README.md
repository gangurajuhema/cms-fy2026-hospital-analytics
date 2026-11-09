# Statistical Analysis – FY2026 Hospital Performance, Quality & Efficiency Analytics

## 1. Project Overview

This module applies statistical methods to the FY2026 CMS hospital performance dataset, covering 2,455 hospitals.

The objective was to investigate the statistical characteristics, variability, performance differences, and relationships among hospital quality-domain scores.

The analysis extends beyond descriptive reporting by applying distribution analysis, relative variability measures, non-parametric hypothesis testing, and rank-based correlation analysis.

Five statistical insights were developed to provide a deeper understanding of hospital performance patterns.

## 2. Analytical Objectives

- Examine the distribution and shape of hospital performance scores.
- Measure relative variability across the four unweighted quality domains.
- Compare domain-level performance across Total Performance Score (TPS) groups.
- Determine whether performance distributions differ significantly across quality domains.
- Evaluate the strength and direction of relationships between quality domains.
- Apply appropriate statistical methods while considering data characteristics and assumptions.

## 3. Statistical Insights and Methodology

### Insight 1 – Distribution Shape and Normality Exploration

**Business Question:** How are hospital performance scores distributed, and do they exhibit characteristics of a normal distribution?

**Methods Applied:**
- Skewness
- Kurtosis
- Histogram analysis
- Normal Q-Q plot

**Analytical Approach:**

Calculated skewness and kurtosis to examine distribution asymmetry and tail behaviour across the four weighted and unweighted quality domains, along with TPS.

Histograms and Q-Q plots were used to visually examine distribution patterns and deviations from normality.

**Key Findings:**
- All examined score distributions exhibited positive skewness.
- Weighted Efficiency had the highest positive skewness.
- Efficiency also exhibited relatively high kurtosis.
- Visual distribution analysis indicated departures from normality, particularly right-skewed patterns.

**Business Value:** Helps assess the distribution characteristics of hospital performance measures and informs the selection of suitable statistical techniques.

### Insight 2 – Relative Variability Across Quality Domains

**Business Question:** Which quality domain exhibits the greatest relative variation in hospital performance?

**Method Applied:** Coefficient of Variation (CV).

**Formula:**

CV = (Sample Standard Deviation / Mean) × 100

**Analytical Approach:**

Calculated the mean, sample standard deviation, and coefficient of variation for the four unweighted quality-domain scores.

**Results:**

| Quality Domain | Coefficient of Variation |
|---|---:|
| Clinical Outcomes | 80.03% |
| Person & Community Engagement | 52.56% |
| Safety | 49.00% |
| Efficiency | 128.13% |

**Key Findings:**
- Efficiency demonstrated the highest relative variability at 128.13%.
- Safety demonstrated the lowest relative variability at 49.00%.
- Clinical Outcomes also showed substantial variation across hospitals.

**Business Value:** Identifies domains where hospital performance is more dispersed relative to their average scores, helping highlight areas for further investigation.

### Insight 3 – Descriptive Performance Comparison Across TPS Groups

**Business Question:** How does average unweighted Efficiency performance vary across hospital TPS groups?

**Method Applied:** Grouped descriptive statistical comparison.

**Analytical Approach:**

Hospitals were classified into four TPS bands, and the average unweighted Efficiency score was calculated for each group.

**Results:**

| TPS Band | Hospitals | Average Efficiency Score |
|---|---:|---:|
| 0–25 | 837 | 5.52 |
| 25–50 | 1,459 | 23.44 |
| 50–75 | 154 | 68.51 |
| 75–100 | 5 | 98.00 |

**Key Findings:**
- Average unweighted Efficiency scores increased across the TPS bands.
- Hospitals in the highest TPS band recorded the highest average Efficiency score.
- The highest TPS group contained only five hospitals, so its average should be interpreted cautiously.

**Business Value:** Provides a descriptive view of how efficiency performance differs across overall hospital performance groups.

**Interpretation Note:** This is a descriptive comparison, not evidence of causation. TPS incorporates weighted Efficiency performance, so the relationship involves mathematical coupling.

### Insight 4 – Comparing Four Quality Domains Using the Friedman Test

**Business Question:** Are there statistically significant differences in the performance distributions of the four quality domains across the same hospitals?

**Method Applied:** Friedman Test (Non-parametric test for related samples).

**Why This Method:**

The same hospitals were evaluated across four related quality-domain measures. The Friedman test was selected to compare these related measurements without relying on the normality assumption of repeated-measures ANOVA.

**Analytical Approach:**
- Used 2,354 hospitals with complete unweighted scores across all four domains.
- Ranked the four domain scores within each hospital.
- Calculated domain rank sums.
- Applied the tie-corrected Friedman statistic.
- Evaluated statistical significance and Kendall's W effect size.

**Results:**

| Measure | Result |
|---|---:|
| Complete hospitals | 2,354 |
| Friedman statistic | 1,523.57 |
| Degrees of freedom | 3 |
| p-value | Less than 0.001 |
| Kendall's W | Approximately 0.216 |

**Rank Sums:**

| Quality Domain | Rank Sum |
|---|---:|
| Clinical Outcomes | 5,240 |
| Person & Community Engagement | 6,777 |
| Safety | 7,296 |
| Efficiency | 4,227 |

**Key Findings:**
- The Friedman test identified statistically significant differences among the four related domain score distributions.
- Safety had the highest rank sum, while Efficiency had the lowest.
- Kendall's W of approximately 0.216 indicated a modest effect size.

**Business Value:** Establishes whether performance differences across quality domains are statistically significant rather than relying only on average-score comparisons.

### Insight 5 – Relationships Between Quality Domains Using Spearman Correlation

**Business Question:** How strongly are the four hospital quality domains associated with one another?

**Methods Applied:**
- Spearman Rank Correlation
- Hypothesis testing for correlation
- Bonferroni multiple-comparison correction

**Why This Method:**

Spearman correlation was used to assess the direction and strength of monotonic relationships between quality-domain scores using ranks, without requiring normally distributed variables.

**Analytical Approach:**
- Calculated pairwise Spearman correlation coefficients for the four unweighted quality domains.
- Evaluated the statistical significance of each correlation.
- Applied Bonferroni correction to account for six pairwise comparisons.

**Correlation Results:**

| Domain Pair | Spearman Correlation |
|---|---:|
| Clinical – Engagement | -0.108 |
| Clinical – Safety | -0.068 |
| Clinical – Efficiency | -0.136 |
| Engagement – Safety | 0.054 |
| Engagement – Efficiency | 0.288 |
| Safety – Efficiency | -0.020 |

**Multiple-Comparison Adjustment:**

Significance level = 0.05

Number of pairwise comparisons = 6

Bonferroni-adjusted significance threshold:

0.05 / 6 = 0.008333

**Key Findings:**
- Engagement and Efficiency showed the strongest positive association (0.288).
- Clinical Outcomes and Efficiency showed the strongest negative association (-0.136).
- Four of the six pairwise relationships remained statistically significant after Bonferroni correction.
- Safety and Efficiency did not show a statistically significant relationship.
- The observed correlations were generally weak.

**Business Value:** Helps identify how performance in one quality domain is associated with performance in another, while controlling for multiple statistical comparisons.

## 4. Statistical Tools and Techniques

**Tool:** Microsoft Excel

**Statistical Techniques:**
- Descriptive statistics
- Skewness and kurtosis
- Histogram and Q-Q plot analysis
- Coefficient of Variation
- Grouped descriptive comparison
- Friedman non-parametric test
- Spearman rank correlation
- Hypothesis testing
- Bonferroni correction
- Kendall's W effect size

## 5. Data Preparation and Validation

- Used the consolidated Master Analysis dataset containing 2,455 hospitals.
- Evaluated missing observations before selecting data for statistical procedures.
- Used complete-case observations where required by the statistical method.
- Used unweighted quality-domain scores for the comparative statistical tests and correlation analysis.
- Used weighted scores for the distribution-shape exploration.
- Checked statistical calculations and results for consistency.

## 6. Overall Statistical Findings

The statistical analysis identified meaningful differences in the distribution and variability of hospital quality-domain scores.

Efficiency showed the highest relative variability, while the Friedman test confirmed statistically significant differences across the four related quality domains. Spearman correlation analysis revealed generally weak relationships, with Engagement and Efficiency displaying the strongest positive association.

Together, these findings provide a deeper statistical understanding of hospital performance beyond dashboard-level comparisons.

## 7. Deliverables

- Statistical analysis workbook.
- Distribution and variability calculations.
- Descriptive comparison across TPS groups.
- Friedman test results and effect-size calculation.
- Spearman correlation matrix and Bonferroni adjustment.
- Supporting statistical charts and visualisations.

## 8. Module Status

**Completed**

All five planned statistical insights were analysed and documented using Microsoft Excel.

