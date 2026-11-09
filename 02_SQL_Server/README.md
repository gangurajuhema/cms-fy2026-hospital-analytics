# SQL Server – Hospital Performance Analysis

## 1. Project Overview

This module focuses on analysing FY2026 hospital performance data using Microsoft SQL Server. Five cleaned CMS datasets were imported, structured, and analysed to investigate hospital performance across key quality and efficiency domains.

The objective was to transform the prepared datasets into meaningful business insights through structured SQL queries.

## 2. Data Sources and Structure

The analysis uses five cleaned datasets:

- Total Performance Score (TPS)
- Clinical Outcomes
- Person and Community Engagement (HCAHPS)
- Safety
- Efficiency and Cost Reduction

Each dataset contains hospital-level information covering 2,455 hospitals.

## 3. Data Preparation and Integration

The following activities were performed:

- Imported all five cleaned datasets into SQL Server.
- Reviewed table structures and data fields.
- Used Fiscal Year and Facility ID as common identifiers for dataset integration.
- Maintained Facility ID and ZIP code as text fields.
- Handled unavailable values by converting "Not Available" entries into NULL values.
- Validated record counts and data consistency across the imported tables.

## 4. SQL Analysis and Business Questions

A structured set of 17 business insights was developed and analysed using SQL Server.

The analysis focused on:

- Hospital performance and Total Performance Scores.
- Performance across individual quality domains.
- Comparisons between hospital performance groups.
- Domain-level strengths and weaknesses.
- Missing data and data availability.
- Relationships and patterns across hospital performance measures.

SQL queries were used to retrieve, filter, group, aggregate, and compare hospital-level information to answer the defined business questions.

## 5. Tools and Techniques

**Database:** Microsoft SQL Server

**SQL techniques:**
- SELECT and WHERE
- GROUP BY and HAVING
- Aggregate functions
- CASE expressions
- Joins
- NULL handling
- Sorting and conditional analysis

## 6. Key Deliverables

- Five imported and structured SQL tables.
- Integrated hospital-level data analysis.
- 17 completed business insights.
- SQL queries supporting the analysis and findings.

## 7. Project Outcome

The SQL analysis provided a structured understanding of hospital performance across the five CMS datasets. It established a database analysis foundation for the subsequent Power BI, Tableau, and statistical analysis stages.

## 8. Module Status

**Completed**

