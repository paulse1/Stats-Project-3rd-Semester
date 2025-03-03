# Stats-Project-3rd-Semester

## Some Example Plots

![alt text](https://raw.githubusercontent.com/paulse1/Stats-Project-3rd-Semester/tree/more-plots/output/figures/cumulative_deaths.png)

![alt text](https://raw.githubusercontent.com/paulse1/Stats-Project-3rd-Semester/tree/more-plots/output/figures/event_type_pie_chart.png)

![alt text](https://raw.githubusercontent.com/paulse1/Stats-Project-3rd-Semester/tree/more-plots/output/figures/event_counter_plot.png)

![alt text](https://raw.githubusercontent.com/paulse1/Stats-Project-3rd-Semester/tree/more-plots/output/figures/daily_casualties.png)

## Project Overview

This project analyzes conflict data in Nigeria, examining the relationship between conflict types and conflict groups while tracking trends over time. The study also visualizes conflicts using heat maps and statistical methods to gain deeper insights.

## Research Questions

This project aims to address the following key questions:

1.  **Is there an association between conflict type and conflict groups?**

2.  **Has the nature of conflicts changed over time?**

3.  **What is the geographical distribution of conflicts in Nigeria?**

4.  **Violence against civilians**

## File Structure

-   **`data/raw/`** → Stores the original dataset (immutable).  
-   **`data/intermediate/`** → Stores cleaned and processed datasets.  
-   **`code/`** → Contains helper functions for data processing.  
-   **`R/`** → Contains main scripts for importing, cleaning, analyzing, and visualizing data.  
-   **`output/`** → Stores all generated outputs, including figures, reports, and tables.  
-   **`setting.R`** → Loads necessary libraries before running analysis.  
-   **`source_all.R`** → Runs all scripts sequentially.

------------------------------------------------------------------------

# Research Proposal: Nigerian Armed Conflict Study

*(Based on ACLED Data)*

## Project Requirements and Objectives

**Core Questions:**

-   Association between conflict types and conflict groups?
-   Do conflict types change over time?

**Research Significance:**

-   Reveal the dynamic patterns of violent conflicts in Nigeria, and identify high-risk groups and event types.
-   Provide data-driven insights for conflict prevention and policy-making.

------------------------------------------------------------------------

## Detailed Workflow and Steps

### I. Data Understanding and Cleaning

#### Data Understanding & Cleaning:

-   **event_id_cnty**

-   **event_date** unify form

-   **year**

-   **time_precision** 1: d/m/y, 2: m/y, 3: y [<https://apidocs.acleddata.com/acled_endpoint.html>]

-   **event_type** 9 categories; clean and to factor

-   **sub_event_type** clean and to factor

-   **actor1** separate new column: if Nigeria; clean; category \*7 [<https://acleddata.com/knowledge-base/codebook/#actor-names-types-and-inter-codes>]

-   **civilian_targeting** clean, to bool

-   **region** clean, useless

-   **location** clean

-   **latitude**

-   **longitude**

-   **geo_precision** 1: to position, 2: to area, 3: to region

-   **source** separate

-   **source_scale** clean, to factor, make long

-   **notes**

-   **fatalities**

-   **timestamp** post time, add time difference

-   **population_best** deal with NA

------------------------------------------------------------------------

### II. Exploratory Data Analysis (EDA)

This part is a general overview of the data behavior. The aim is through ituitive understanding of the dataset, form hypothesis for advanced analysis

#### Descriptive Statistics:

-   **Variables / Objects**
    -   **Type, group alone:** (understand how variables/objects function)
        -   **Type with subtype**
        -   **Group:** top ten? If Nigeria? categorized group
-   **Association Analysis**
    -   **Type + Group:**
        -   **Type or Subtype:** selection criteria
        -   **how to represent:** Top xx? Nigeria? category?
    -   **Fatalities / Population:** (influence on objects)
        -   With type or subtype needs to be checked
        -   Check group effects
-   **Time Related** (periodicity)
    -   **Year / Month:** general and main type, total number
    -   **Year / Month:** top xx? / categorized group
-   **Geology Related**
    -   Geo + Main Type / Sub Type
    -   Geo + Top xx? / Categorized Group

#### Possible Visualizations:

-   **Conflict Type Distribution:** 
    -   Calculate the proportion of each event type (e.g., “Violence against civilians” might account for 35%).
-   **Major Conflict Groups:** 
    -   List the top 10 most active groups (e.g., “Boko Haram,” “Fulani Ethnic Militia”).
-   **Casualty Analysis:** 
    -   Compute average casualty figures and identify event types with high fatality counts (e.g., “Explosions/Remote Violence”).
-   **Time Trend Chart:** 
    -   Count conflict events by year or month to observe overall trends (e.g., a surge in conflicts post-2009).
-   **Conflict Type Distribution:** 
    -   Use a pie chart to display the proportion of each event type, and a stacked bar chart to show group-specific preferences.
-   **Geographical Heat Map:** 
    -   Plot conflicts using latitude and longitude to highlight high-risk areas (e.g., northeastern Borno State).
-   **Group-Event Association Matrix:** 
    -   Create a heat map to show the concentration of event types by different groups.

------------------------------------------------------------------------

### III. Hypothesis Testing and Analysis

Assumed that we already have our hypothesis from EDA, we need to do advanced analysis to confirm them. Here using **Association Analysis** and **Series Analysis**. Variables should be within Group, type, fatalities, population. Series should be time and geology.

#### Association Between Conflict Types and Groups:

-   **Chi-Square Test:** Test the independence between event types and group distributions (e.g., if p \< 0.05, reject the hypothesis of independence).
-   **Cramer’s V Coefficient:** Quantify the strength of the association (e.g., a value of 0.3 suggests a moderate association).

#### Time Series Analysis:

-   **Segmented Trends:** Analyze changes in the proportions of event types over 5-year intervals (e.g., an increase in “riots” from 2000–2005).
-   **Seasonal Analysis:** Examine whether conflicts occur more frequently in certain months (e.g., during the rainy season, which may be related to resource disputes).

#### Geographical Clustering:

-   **Spatial Autocorrelation:** Use Moran’s I index to detect the geographical clustering of conflict events.
-   **Hotspot Analysis:** Identify statistically significant high-incidence areas (e.g., zones in the northeast where ISWAP is highly active).

------------------------------------------------------------------------

### IV. In-Depth Analysis and Interpretation  

Here we answer the questions about hypothesis.

**Key Group Analysis:**

-   **Boko Haram:** Dominates “Explosions/Remote Violence,” is concentrated in the northeast, and has shown a surge in activity after 2010.
-   **Fulani Ethnic Militia:** Frequently involved in “Violence against civilians,” often linked to conflicts over agricultural and pastoral resources.

**Event Type Evolution:**

-   Prior to 2000, protests were predominant; after 2010, there was a significant increase in “kidnappings” and “explosions.”

**Casualty Association:**

-   “Battles” tend to have the highest average fatalities, often due to armed exchanges during military operations.

------------------------------------------------------------------------

### V. Statistical Modeling and Hypothesis Testing

The concept should be give advice to the government about:  
-   **Security** I.e. in Aug, more defense in northern area against group Boko and type Battles
-   **Society** i.e. avoid resource disputes among civilians in certain seasons

#### Regression and Causal Analysis
-   **Build regression models** (e.g., multiple regression or logistic regression) to explore whether conflict types can be explained by group attributes or time factors.
-   **Conduct hypothesis tests** to verify whether the relationship between conflict types and group as well as time variables is statistically significant.

#### Model Diagnostics and Optimization
-   Evaluate the model's fit by diagnosing residual distributions, multicollinearity issues, etc.
-   Improve and optimize the model based on the diagnostic results to ensure that the interpretations are reasonable.

------------------------------------------------------------------------

### VI. Visualization and Report Writing

**Core Visualizations:**

-   **Animated Time Trend Map:** An animation that shows the spatial diffusion of conflict events over time.
-   **Association Network Graph:** A network diagram displaying the many-to-many relationships between conflict groups and event types, where node size indicates the level of activity.
-   **Interactive Heat Map:** Allows users to filter geographical distributions by time.

**Report Structure:**

-   **Abstract:** Summarize key findings (e.g., “Strong association between Boko Haram and explosion events”).
-   **Methodology:** Detail the data cleaning processes and statistical models used (e.g., Chi-square tests, time series decomposition).
-   **Results:** Combine charts and narrative explanations to highlight spatiotemporal patterns and associations.
-   **Recommendations:** Advise on enhancing security in the northeast and monitoring hotspots of resource conflicts.

------------------------------------------------------------------------

## Key Dimensions in Sociological Research

-   **Structural Factors:** Economic inequality, resource distribution, and ethnic conflicts.
-   **Actor Motivations:** Political power struggles, religious ideologies, and economic interests.
-   **Spatiotemporal Dynamics:** Seasonality of conflicts, geographical diffusion patterns, and the effects of policy interventions.

