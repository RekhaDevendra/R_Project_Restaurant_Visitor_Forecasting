# Name: Rekha Devendra
# Statistical Forecasting Project 
# Forecasting Restaurant Visitor Data for Operational Planning

# Load necessary libraries ------------------------------------------------
library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)
library(lubridate)
library(gridExtra)
library(fpp3)
library(readr)


# Set seed for reproducibility
set.seed(42)

# 1. Data Loading and Preprocessing ---------------------------------------

# Load the dataset

data <- read_csv("air_visit_data.csv/air_visit_data.csv")
View(data)


# Convert visit_date to Date type
data$visit_date <- as.Date(data$visit_date)

# Filter data for a specific restaurant (adjust air_store_id as needed)
chosen_restaurant_id <- "air_ba937bf13d40fb24"  # Example restaurant ID
data_filtered <- data %>% filter(air_store_id == chosen_restaurant_id)

# Check and remove any duplicates
data_filtered <- data_filtered %>% distinct()

# Check for gaps in the date range and fill missing dates
full_date_range <- data.frame(visit_date = seq(min(data_filtered$visit_date), max(data_filtered$visit_date), by = "day"))
data_full <- left_join(full_date_range, data_filtered, by = "visit_date")

# Fill missing visitor values with 0 (restaurant closed on certain days)
data_full$visitors[is.na(data_full$visitors)] <- 0

# Check for missing values
sum(is.na(data))

# Split data into training and testing sets (80/20 split)
train_size <- round(0.8 * nrow(data_full))
train_data <- data_full[1:train_size, ]
test_data <- data_full[(train_size + 1):nrow(data_full), ]

# 2. Visualization --------------------------------------------------------

# Time Plot of Visitors Over Time
ggplot(train_data, aes(x = visit_date, y = visitors)) +
  geom_line(color = "blue", size = 1) +  # Line color and thickness
  geom_point(color = "red", size = 2) +  # Points to highlight data points
  labs(
    title = "Daily Visitors Over Time",
    x = "Date",
    y = "Number of Visitors",
    caption = "Data Source: Recruit Restaurant Visitor Forecasting Dataset"
  ) +
  theme_minimal(base_size = 14) +  # Increased base font size
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    axis.title = element_text(face = "bold"),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_blank()
  )

# ACF plot for visitors
acf_plot <- ggAcf(train_data$visitors, lag.max = 30) +
  labs(title = "ACF Plot for Visitors", x = "Lag", y = "ACF")
print(acf_plot)

# 3. Data Transformation --------------------------------------------------

# Decomposition of Visitors Time Series
decomp <- stl(ts(train_data$visitors, frequency = 7), s.window = "periodic")
autoplot(decomp) +
  labs(title = "Decomposition of Visitors Time Series")

# Log transformation of visitors (adding 1 to avoid log(0))
train_data$visitors_transformed <- log(train_data$visitors + 1)

# Convert transformed data to a time series object
ts_train <- ts(train_data$visitors_transformed, frequency = 7)

# 4. Forecasting and Analysis ---------------------------------------------------

# ARIMA Model
arima_model <- auto.arima(ts_train)
arima_forecast <- forecast(arima_model, h = nrow(test_data))

# Plot ARIMA Forecast
autoplot(arima_forecast) +
  ggtitle("ARIMA Model Forecast") +
  xlab("Date") +
  ylab("Number of Visitors")

# ETS Model
ets_model <- ets(ts_train)
ets_forecast <- forecast(ets_model, h = nrow(test_data))

# Plot ETS Forecast
autoplot(ets_forecast) +
  ggtitle("ETS Model Forecast") +
  xlab("Date") +
  ylab("Number of Visitors")

# Seasonal Naive Model
sn_model <- snaive(ts_train, h = nrow(test_data))
sn_forecast <- forecast(sn_model, h = nrow(test_data))

# Plot Seasonal Naive Forecast
autoplot(sn_forecast) +
  ggtitle("Seasonal Naive Model Forecast") +
  xlab("Date") +
  ylab("Number of Visitors")

# Simple Exponential Smoothing (SES)
ses_model <- ses(ts_train, h = nrow(test_data))
ses_forecast <- forecast(ses_model, h = nrow(test_data))

# Plot SES Forecast
autoplot(ses_forecast) +
  ggtitle("Simple Exponential Smoothing Forecast") +
  xlab("Date") +
  ylab("Number of Visitors")


# 5. Time Series Regression ------------------------------------------------

# Create a time index for linear regression model
train_data$time_index <- 1:nrow(train_data)

# Fit the linear model
lin_model <- lm(visitors ~ time_index, data = train_data)

# Create the time index for the test data
test_data$time_index <- (nrow(train_data) + 1):(nrow(train_data) + nrow(test_data))

# Forecast using the linear regression model
lin_forecast <- predict(lin_model, newdata = test_data)

# Time Series Regression with Trend and Seasonality
visitors_ts <- data_full %>%
  as_tsibble(index = visit_date) %>%
  select(visit_date, visitors)

# Model: Linear Regression with Time and Seasonality
multiple_fit <- visitors_ts %>%
  model(TSLM(visitors ~ trend() + as.factor(month(visit_date))))

# Report the model results
multiple_fit %>% report()

# Check residuals
multiple_fit %>% 
  gg_tsresiduals() + 
  ggtitle("Residual Analysis of Linear Regression Model")  # Add the title


# Generate forecasts for 12 months
fc <- forecast(multiple_fit, h = "12 months")

# Plot the forecasts
visitors_ts %>%
  autoplot(visitors) +
  autolayer(fc) +
  labs(title = "Visitor Forecasts (Regression Model)", y = "Number of Visitors")

# 6. Forecasting Performance ----------------------------------------------------

# Calculate accuracy for ARIMA, ETS, Seasonal Naive, SES, and Linear Regression
arima_accuracy <- accuracy(arima_forecast, test_data$visitors)
ets_accuracy <- accuracy(ets_forecast, test_data$visitors)
sn_accuracy <- accuracy(sn_forecast, test_data$visitors)
ses_accuracy <- accuracy(ses_forecast, test_data$visitors)
lin_accuracy <- accuracy(lin_forecast, test_data$visitors)

# Combine accuracy results into a data frame
accuracy_results <- data.frame(
  Model = c("ARIMA", "ETS", "Seasonal Naive", "SES", "Linear Regression"),
  RMSE = c(arima_accuracy[2], ets_accuracy[2], sn_accuracy[2], ses_accuracy[2], lin_accuracy[2]),
  MAE = c(arima_accuracy[3], ets_accuracy[3], sn_accuracy[3], ses_accuracy[3], lin_accuracy[3])
)

# Print accuracy results
print(accuracy_results)

# 7. Residual Analysis ----------------------------------------------------

# Residual diagnostics for ARIMA
checkresiduals(arima_forecast)

# Residual diagnostics for ETS
checkresiduals(ets_forecast)
