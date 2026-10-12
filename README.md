# Baby Name Trends Analysis — SQL

An SQL-based analysis of U.S. baby name trends from 1980 to 2009, exploring name popularity over time, across genders, and across geographic regions.

## Overview

This project explores U.S. baby name data using SQL to investigate naming trends, popularity rankings, and geographic differences. The analysis covers popular names by year and decade, changes in popularity rankings, regional naming patterns, and unique name characteristics.

I used nested subqueries throughout the project instead of Common Table Expressions (CTEs) as a deliberate exercise to strengthen my understanding of subquery-based problem-solving.

## Project Objectives

- **Track changes in name popularity:** Identify the most popular boy and girl names and examine how their rankings change over time.
- **Compare popularity across decades:** Find the top three names for each gender by decade and compare naming trends.
- **Analyze regional differences:** Compare birth counts across U.S. regions and identify the most popular names within each region.
- **Explore unique name characteristics:** Investigate androgynous names, name lengths, and the percentage of babies named Chris across states.

## Data Quality Findings

During data inspection, I identified inconsistencies in the regional mapping data and addressed them in the SQL queries:

- **Missing state-to-region mapping:** Michigan (`MI`) appeared in the `names` table but was missing from the `regions` table. I incorporated a Michigan-to-Midwest mapping using `UNION`.
- **Inconsistent region labels:** New England appeared as both `New England` and `New_England`. I normalized the label to `New_England` using conditional logic.

These adjustments allowed the regional analyses to use more consistent geographic classifications.

## SQL Techniques

- **Subqueries:** Used nested queries to calculate intermediate results, filter ranked records, and organize multi-step analyses without CTEs.
- **Window functions:** Applied `RANK()` with `PARTITION BY` to determine popularity rankings by year, decade, gender, and region.
- **Aggregation:** Used `SUM()`, `COUNT()`, `MAX()`, and `MIN()` to summarize births and examine name characteristics.
- **Joins and set operations:** Combined name data with regional mappings and handled missing geographic mappings.
- **Conditional logic:** Used `CASE` expressions to classify years into decades and standardize region labels.
- **Filtering and percentages:** Applied `WHERE`, `HAVING`, and filtered aggregates to identify names and calculate state-level percentages.

## Dataset

The project uses two tables:

| Table | Description |
|---|---|
| `names` | State, gender, year, name, and number of births associated with each name. |
| `regions` | State abbreviations and their corresponding U.S. regions. |

The accompanying `baby_names_db_data_dictionary.csv` documents the fields in both tables.

## Files

- `babynames.sql` — SQL queries covering the project objectives.
- `baby_names_db_data_dictionary.csv` — Field definitions for the source tables.

## Project Context

Completed as a guided project from Maven Analytics to practice advanced SQL querying and analytical problem-solving using baby name data.
