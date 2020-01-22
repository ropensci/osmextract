# Aim: test gdal's interleaved settings

gdal-config --version

wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf

ogr2ogr \
  -f GPKG lnd.gpkg \
  greater-london-latest.osm.pbf \
  "lines"

