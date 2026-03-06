import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER


# 1. Open the GRIB file with the filter that worked
ds = xr.open_dataset(
    'surface.grib', 
    engine='cfgrib', 
    backend_kwargs={'filter_by_keys': {'typeOfLevel': 'surface'}}
)

# 2. Extract the specific time: April 28, 2011 at 00:00 UTC
# Using .sel(time=...) handles the extraction from the 'time' dimension
target_time = '2011-04-28T00:00:00'
ds_00z = ds.sel(time=target_time)

# 3. Fix Longitude for Cartopy (-180 to 180)
# ERA5 defaults to 0-360; this shift aligns it with your shapefiles
ds_00z.coords['longitude'] = (ds_00z.coords['longitude'] + 180) % 360 - 180
ds_00z = ds_00z.sortby('longitude')

# 4. Subset for the Southeast US (Matches your WRF/Pangu plots)
lat_slice = slice(40, 30)   # North to South
lon_slice = slice(-95, -80) # West to East

ds_final = ds_00z.sel(latitude=lat_slice, longitude=lon_slice)

# 5. Save to NetCDF
output_name = 'era5_2011-04-28_00z_subset.nc'
ds_final.to_netcdf(output_name)

print(f"Successfully saved {output_name}")



# Load the new subset
ds_plot = xr.open_dataset('era5_2011-04-28_00z_subset.nc')
t2m_c = ds_plot['t2m'] - 273.15  # Convert Kelvin to Celsius

fig = plt.figure(figsize=(12, 8))
ax = plt.axes(projection=ccrs.PlateCarree())

# Add State Lines
shp_path = 'state_lines/ne_50m_admin_1_states_provinces.shp'
reader = shpreader.Reader(shp_path)
ax.add_geometries(reader.geometries(), ccrs.PlateCarree(), 
                  facecolor='none', edgecolor='black', linewidth=0.8)

# Plot
mesh = t2m_c.plot(ax=ax, transform=ccrs.PlateCarree(), cmap='RdYlBu_r',
                  cbar_kwargs={'label': 'Temperature (°C)'})

# Apply your preferred style: Two-sided, Degrees-Minutes
gl = ax.gridlines(draw_labels=True, dms=True, linestyle='--', color='gray', alpha=0.5)
gl.top_labels = False
gl.right_labels = False
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

plt.title("ERA5 Reanalysis: April 28, 2011 (00:00 UTC)", fontsize=14)

# Save the PNG
plt.savefig('era5_2011_outbreak_map.png', dpi=300, bbox_inches='tight')
