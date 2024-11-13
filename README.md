# Restaurant Visitor Forecasting

## Project Overview
This project aims to predict restaurant visitor counts using historical data. The dataset, sourced from [Kaggle's Recruit Restaurant Visitor Forecasting dataset](https://www.kaggle.com/c/recruit-restaurant-visitor-forecasting/data), contains information on restaurant visits, allowing us to build time series forecasting models to help restaurant managers optimize operations.

## Dataset Information
The dataset includes:
- **air_store_id**: Unique identifier for each restaurant.
- **visit_date**: Date of the visit.
- **visitors**: Number of visitors on that date.

Data cleaning included duplicate removal, handling missing data, and filtering for a specific restaurant by `air_store_id`.

## Objectives
1. Develop forecasting models to predict future restaurant visitors, especially during high-traffic periods like Japan’s Golden Week.
2. Provide actionable insights for restaurant managers to optimize staffing and inventory based on forecasted visitor trends.

## Practical Problem
Accurate visitor forecasts can help managers make informed decisions on staffing, inventory management, and operational efficiency. This project aims to address operational challenges, especially during peak demand times, through predictive analytics.

## Methodology
1. **Data Preparation**:
   - Import data and handle duplicates/missing values.
   - Filter for a specific restaurant.
   - Split data into training (80%) and testing (20%) sets.
   
2. **Visualization**:
   - Time plot of visitor data.
   - Autocorrelation function (ACF) plot.

3. **Data Transformation**:
   - Decompose the visitor time series data.

4. **Forecasting Models**:
   - ARIMA
   - ETS
   - Seasonal Naive Model
   - Simple Exponential Smoothing (SES)
   - Time Series Regression (TSLM)

5. **Model Evaluation**:
   - Residual analysis for forecast performance.

## Conclusion
The project demonstrates how predictive models can inform restaurant management decisions and improve service delivery during fluctuating visitor periods.

## Files and Directories
- `data/`: Contains data files (e.g., `air_visit_data.csv`).
- `scripts/`: Contains R scripts for data processing, modeling, and visualization.
- **docs/**: Contains the project documentation (`Project_Documentation.docx` and `Project_Documentation.pdf`) with detailed explanations.


## Steps to Reproduce
1. Run the Analysis: Use the R code file located in the `scripts/` folder.
2. Review the Documentation: The project’s methodology, findings, and recommendations are detailed in the Word/PDF documentation in the `docs/` folder.

## Contact
For questions or collaboration, please reach out through GitHub.

