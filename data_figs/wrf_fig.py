import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Load your April 2011 dataset
ds = xr.open_dataset('wrfout_d01_2011-04-28_00:00:00')

# 1. Define your geographic boundaries
lat_min, lat_max = 30.0, 40.0
lon_min, lon_max = -95.0, -80.0

# 2. Create a mask based on the 2D coordinate variables
# Note: Check if your file uses 'XLAT' or 'lat' in ds.coords
mask = (
    (ds.XLAT >= lat_min) & (ds.XLAT <= lat_max) & 
    (ds.XLONG >= lon_min) & (ds.XLONG <= lon_max)
)

# 3. Apply the mask
# 'drop=True' removes the grid cells outside your range
subset = ds.where(mask, drop=True)

# Save your new regional file
subset.to_netcdf('regional_wrfout_2011-04-28_00:00:00.nc')




# 1. Load your subsetted data
ds = xr.open_dataset('regional_wrfout_2011-04-28_00:00:00.nc')

# Extract 2m Temp and convert Kelvin to Celsius
t2 = ds['T2'].isel(Time=0) - 273.15

# 2. Point to your unzipped shapefile
shp_path = 'state_lines/ne_50m_admin_1_states_provinces.shp'

# 3. Setup the Figure
fig = plt.figure(figsize=(12, 9))
# Using PlateCarree here ensures the "flat/rectangular" look of the Pangu plot
ax = plt.axes(projection=ccrs.PlateCarree())

# 4. Add the Local State Lines
reader = shpreader.Reader(shp_path)
ax.add_geometries(reader.geometries(), ccrs.PlateCarree(), 
                  facecolor='none', edgecolor='black', linewidth=0.8)

# 5. Plot the Temperature Data
mesh = t2.plot(
    ax=ax, 
    x='XLONG', 
    y='XLAT', 
    transform=ccrs.PlateCarree(),
    cmap='RdYlBu_r', 
    add_colorbar=False 
)

# Add a customized colorbar
cbar = plt.colorbar(mesh, ax=ax, orientation='vertical', pad=0.03, shrink=0.7)
cbar.set_label('2m Temperature (°C)', fontsize=12)

# 6. Final Formatting
# Change dms=False and explicitly disable top/right labels
gl = ax.gridlines(draw_labels=True, dms=False, x_inline=False, y_inline=False, 
                  linestyle='--', color='gray', alpha=0.5)

gl.top_labels = False    # Disable top labels to match Pangu
gl.right_labels = False  # Disable right labels to match Pangu

# Use formatters to add the °N and °W symbols to the decimals
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

plt.title("Surface Temperature: April 28, 2011 (00:00 UTC)", fontsize=14)

# Save as PNG
plt.savefig('wrf_2mtemp_April_27_2011.png', dpi=300, bbox_inches='tight')
print("Plot successfully saved as 'wrf_2mtemp_April_27_2011.png'")

