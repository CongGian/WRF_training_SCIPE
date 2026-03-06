import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.io.shapereader as shpreader
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Load your Pangu-Weather file
ds = xr.open_dataset('output_surface_2011-04-28-00-00.nc')

# Use the full names 'latitude' and 'longitude'
subset = ds.sel(
    latitude=slice(40, 30),   # Pangu often goes North to South (90 to -90)
    longitude=slice(265, 280) # Pangu usually uses 0-360 convention
)

subset.to_netcdf('regional_surface_2011-04-28-00-00.nc')



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
plt.savefig('pangu_2mtemp_April_27_2011.png', dpi=300, bbox_inches='tight')
print("Plot successfully saved as 'pangu_2mtemp_April_27_2011.png'")
