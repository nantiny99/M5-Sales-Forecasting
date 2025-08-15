# Set your working directory to the folder where your CSV files are
setwd("C:/Users/User/Desktop/usm/self learning/M5 Forecast")
# Check it worked
getwd()

install.packages("tidyverse")
library(tidyverse)
packageVersion("tidyverse")

# Read the CSVs
sales_data <- read_csv("sales_train_validation.csv")
calendar_data <- read_csv("calendar.csv")
sell_prices <- read_csv("sell_prices.csv")
sales_eval <- read_csv("sales_train_evaluation.csv")
sample_sub <- read_csv("sample_submission.csv")

# Check first few rows of sales data
head(sales_data)

dim(sales_data)    # number of rows and columns
summary(sales_data)

sales_data %>% select(1:5) %>% head()


# Find the product with highest total sales
top_product_id <- sales_data %>%
  mutate(total_sales = rowSums(select(., starts_with("d_")))) %>%
  arrange(desc(total_sales)) %>%
  slice(1) %>%
  pull(id)

# Select that product's sales
one_product <- sales_data %>% filter(id == top_product_id)


# See the product ID
one_product$id

one_product_long <- one_product %>%
  pivot_longer(cols = starts_with("d_"), 
               names_to = "day", 
               values_to = "sales")

# Join with calendar to get the actual date
one_product_long <- one_product_long %>%
  left_join(calendar_data, by = c("day" = "d")) %>%
  select(date, sales)

# Make sure date is in Date format
one_product_long$date <- as.Date(one_product_long$date)

# Arrange by date
one_product_long <- one_product_long %>%
  arrange(date)

library(forecast)
library(prophet)

library(ggplot2)


ggplot(one_product_long, aes(x = date, y = sales)) +
  geom_line(color = "steelblue") +
  labs(title = "Daily Sales for One Product",
       x = "Date", y = "Sales")


start_year <- as.numeric(format(min(one_product_long$date), "%Y"))
start_doy  <- as.numeric(format(min(one_product_long$date), "%j"))
sales_ts <- ts(one_product_long$sales, start = c(start_year, start_doy), frequency = 365)


# Fit ARIMA model
fit_arima <- auto.arima(sales_ts)

# Forecast next 30 days
forecast_arima <- forecast(fit_arima, h = 30)

# Create forecast dataframe with actual dates
arima_forecast_df <- data.frame(
  date = seq(max(one_product_long$date) + 1, by = "day", length.out = 30),
  forecast = as.numeric(forecast_arima$mean)
)

# Plot actual sales + ARIMA forecast with date labels
ggplot() +
  geom_line(data = one_product_long, aes(x = date, y = sales), color = "steelblue") +
  geom_line(data = arima_forecast_df, aes(x = date, y = forecast), color = "red") +
  labs(title = "ARIMA Forecast (Next 30 Days)",
       x = "Date", y = "Sales") +
  theme_minimal()




# Prepare data for Prophet
prophet_data <- one_product_long %>%
  rename(ds = date, y = sales)

# Fit Prophet model
fit_prophet <- prophet(prophet_data)

# Make future dataframe for 30 days ahead
future <- make_future_dataframe(fit_prophet, periods = 30)

# Forecast
forecast_prophet <- predict(fit_prophet, future)

# Plot Prophet forecast
plot(fit_prophet, forecast_prophet)
prophet_plot_components(fit_prophet, forecast_prophet)



library(Metrics)

# ---------------------------
# Prophet training only on train_data
prophet_train <- train_data %>% rename(ds = date, y = sales)
fit_prophet <- prophet(prophet_train)

future <- make_future_dataframe(fit_prophet, periods = 30)
forecast_prophet <- predict(fit_prophet, future)

# Extract only the forecast part
prophet_forecast_vals <- tail(forecast_prophet$yhat, 30)

sales_ts_train <- ts(train_data$sales, frequency = 7)
fit_arima <- auto.arima(sales_ts_train)
forecast_arima <- forecast(fit_arima, h = 30)

arima_rmse <- rmse(test_data$sales, forecast_arima$mean)
arima_mae <- mae(test_data$sales, forecast_arima$mean)



# --- Prophet ---
prophet_train <- train_data %>%
  rename(ds = date, y = sales)

fit_prophet <- prophet(prophet_train)
future <- make_future_dataframe(fit_prophet, periods = 30)
forecast_prophet <- predict(fit_prophet, future)

# Prophet forecast values (last 30 days)
prophet_forecast_vals <- tail(forecast_prophet$yhat, 30)

prophet_rmse <- rmse(test_data$sales, prophet_forecast_vals)
prophet_mae <- mae(test_data$sales, prophet_forecast_vals)

# ---------------------------
# Summary table
# ---------------------------
comparison <- data.frame(
  Model = c("ARIMA", "Prophet"),
  RMSE = c(round(arima_rmse, 2), round(prophet_rmse, 2)),
  MAPE_percent = c(round(arima_mae, 2), round(prophet_mae, 2))
)

print(comparison)

# Save the comparison table as CSV
write.csv(comparison, "metrics_table1.csv", row.names = FALSE)

