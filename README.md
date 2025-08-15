# Sales Forecasting using ARIMA & Prophet (M5 Dataset)

## Project Overview
This project forecasts daily sales for the top-selling product in the M5 Forecasting dataset using two time series models, **ARIMA** and **Prophet** in R.  
The goal is to compare model performance and identify the most accurate forecasting approach.

## Dataset
The project uses data from the [M5 Forecasting - Accuracy competition](https://www.kaggle.com/competitions/m5-forecasting-accuracy):
- `sales_train_validation.csv` – Historical daily unit sales
- `calendar.csv` – Date mapping and special event details
- `sell_prices.csv` – Price data for each product/store
- `sales_train_evaluation.csv` – Evaluation period sales
- `sample_submission.csv` – Submission format (reference only)

## Tools & Libraries
- **Language:** R
- **Packages:** tidyverse, forecast, prophet, ggplot2, Metrics

## Workflow
1. **Load Data**  
   Import CSV files and inspect basic structure.

2. **Select Target Product**  
   Identify product with highest total sales.

3. **Transform Data**  
   Convert sales data from wide to long format and merge with calendar dates.

4. **Model Training**
   - **ARIMA**: Auto ARIMA model using `forecast` package
   - **Prophet**: Forecasting model using Facebook’s Prophet package

5. **Evaluation**
   Compare models using:
   - **RMSE** (Root Mean Squared Error)
   - **MAE** (Mean Absolute Error)

6. **Visualization**
   - Daily sales line chart
   - Forecast plots for both ARIMA & Prophet

## Results
| Model   | RMSE | MAE (%) |
|---------|------|---------|
| ARIMA   | 0.38 | 0.34    |
| Prophet | 0.90 | 0.86    |

**Conclusion:** ARIMA achieved lower error rates and is the preferred model for this dataset.
