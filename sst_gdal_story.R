library(raadfiles)
library(dplyr)
files <- oisst_daily_files()

(sstfile <- files |>  slice_max(date) |> pull(fullname))

library(vapour)  ## my rasterio/fiona (more or less)
vapour:::gdalinfo_internal(sstfile, json = F) |> writeLines()


## fully qualified GDAL DSN (sub)dataset
(sstsds <- vapour::vapour_sds_names(sstfile) |> grep(pattern = ":sst$", value = TRUE))
vapour:::gdalinfo_internal(sstsds, json = F) |> writeLines()

vapour_raster_info(sstsds)


(fq_sstds <- vapour_vrt(sstsds, projection = "OGC:CRS84")) |> writeLines()


read_gdal <- function(dsn, dimension = NULL, extent = NULL, crs = NULL, ...) {
  info <- vapour::vapour_raster_info(dsn)
  if (is.null(dimension)) dimension <- info$dimension
  if (is.null(extent)) extent <- info$extent
  if (is.null(crs)) crs <- info$projection
  matrix(
    vapour::vapour_warp_raster_dbl(dsn, dimension = dimension, extent = extent, projection = crs, ...),
    dimension[2L], byrow = TRUE)

}

sst <- read_gdal(fq_sstds)
library(ximage)
ximage(sst, extent = c(0, 360, -90, 90), asp = 1)


ex <- c(-1, 1, -1, 1) * 1e6
psst <- read_gdal(fq_sstds, extent = ex, dimension = c(1024, 1024), crs = "+proj=laea +lon_0=147 +lat_0=-42")

ximage(psst, extent = ex, asp = 1, col = hcl.colors(128))



plot(sstx)
