#1/bin/bash

##################################
## Data Preparation and Running ##
##################################

## Unzip input data directories 
tar -xJvf data_input.tar.xz

# Create "models" folder and download the weights into it
mkdir models
## Model Weights download link located in official repo 
#(https://github.com/198808xc/Pangu-Weather/tree/main?tab=readme-ov-file#global-weather-forecasting-inference-using-the-trained-models)

# 1. Edit the file to the initial start time that you want

# 2. Run data_prepare.py to download the initial field data and convert them to numpy array (Edit to correct date)
# python data_prepare.py # Only needed if initial netcdf input files are downloaded

# 3. Modify the variables in inference.py according to your needs:

# 4. Run inference.py to make a forecast
python inference.py 

# 5. Modify the date_time and final_date_time of the initial field in forecast_decode.py

# 6. After making the forecast, run forecast_decode.py to convert the numpy array back to NetCDF format
python forecast_decode.py

# 7. Visualize Results

