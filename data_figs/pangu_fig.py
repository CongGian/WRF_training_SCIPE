import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
import os


# Load your Pangu-Weather file
ds = xr.open_dataset('output_surface_2011-04-28-00-00.nc')

# Use the full names 'latitude' and 'longitude'
subset = ds.sel(
    latitude=slice(50, 25),   # Pangu often goes North to South (90 to -90)
    longitude=slice(235, 295) # Pangu usually uses 0-360 convention
)

# Rm old file and create new
os.system('rm regional_surface_2011-04-28-00-00.nc')
subset.to_netcdf('regional_surface_2011-04-28-00-00.nc')



# Load the new subset
ds_plot = xr.open_dataset('era5_2011-04-28_00z_subset.nc')
t2m_c = ds_plot['t2m'] - 273.15  # Convert Kelvin to Celsius


# Define universal constants for both plots
T_MIN, T_MAX = -20, 35

fig = plt.figure(figsize=(12, 9)) # Use same figsize as WRF
ax = plt.axes(projection=ccrs.PlateCarree())

# Add State Lines
# Add the Local State Lines
shp_path = 'state_lines/ne_50m_admin_1_states_provinces.shp'
reader = shpreader.Reader(shp_path)
ax.add_geometries(reader.geometries(), ccrs.PlateCarree(), 
                  facecolor='none', edgecolor='black', linewidth=0.8)

# Plot with SAME FIXED LIMITS
mesh = t2m_c.plot(
    ax=ax, 
    transform=ccrs.PlateCarree(), 
    cmap='nipy_spectral',
    vmin=T_MIN,      # Must match WRF
    vmax=T_MAX,      # Must match WRF
    add_colorbar=False 
)

# Use the FIG object here too
cbar = fig.colorbar(mesh, ax=ax, orientation='vertical', pad=0.03, shrink=0.7)
cbar.set_label('2m Temperature (°C)', fontsize=12)

# Standardize the map zoom (Extents) to match WRF exactly
ax.set_extent([-125, -66, 25, 50], crs=ccrs.PlateCarree())

# Formatting
gl = ax.gridlines(draw_labels=True, dms=False, x_inline=False, y_inline=False, 
                  linestyle='--', color='gray', alpha=0.5)
gl.top_labels = False
gl.right_labels = False
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

plt.title("ERA5 Reanalysis 2m Temperature: April 28, 2011 (00:00 UTC)", fontsize=14)

# Save as PNG
plt.savefig('pangu_2mtemp_April_27_2011.png', dpi=300, bbox_inches='tight')
print("Plot successfully saved as 'pangu_2mtemp_April_27_2011.png'")
