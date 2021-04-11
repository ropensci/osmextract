# Aim: test gdal queries

wget https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf

ogrinfo its-example.osm.pbf
ogrinfo its-example.osm.pbf lines
ogrinfo \
  -dialect sqlite -sql "SELECT highway, COUNT(*) from lines" \
  its-example.osm.pbf > out.txt
cat out.txt

ogrinfo \
  -dialect sqlite -sql "SELECT highway, COUNT(*) from lines" \
  its-example.osm.pbf > out.txt

ogrinfo \
  -dialect sqlite -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle, hstore_get_value(other_tags, 'foot') AS foot FROM lines" \
  its-example.osm.pbf > out.txt

ogrinfo \
  -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle, hstore_get_value(other_tags, 'foot') AS foot FROM lines" \
  its-example.osm.pbf > out.txt

ogrinfo \
  -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle FROM lines" \
  its-example.osm.pbf > out.txt

cat out.txt

ogrinfo \
  -sql "SELECT hstore_get_value(other_tags, 'bicycle') AS bicycle FROM lines" \
  its-example.osm.pbf > out.txt

```{bash, eval = Sys.which("bash") != ""}
echo "Hello Bash!";
pwd;
ls | head;


cat out.txt


ogrinfo -dialect sqlite -sql "SELECT road_name, COUNT(*) FROM roads AS roadcnt GROUP BY road_name HAVING roadcnt=1" roads.shp >report.txt

ogrinfo its-example.osm.pbf
ogr2ogr \
  - where its-example.osm.pbf

ogr2ogr \
  -where "\"POP_EST\" < 1000000" \
  -f GPKG output.gpkg \
  natural_earth_vector.gpkg \
  ne_10m_admin_0_countries
