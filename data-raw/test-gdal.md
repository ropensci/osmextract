Test ogr queries
================

``` bash
echo "Hello Bash!";
pwd;
ls | head;
```

    ## Hello Bash!
    ## /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/atfutures/itsleeds/osmextract/data-raw
    ## bbbike_zones.R
    ## geofabrik_zones.R
    ## its-example.osm.pbf
    ## its-example.osm.pbf.1
    ## its-example.osm.pbf.2
    ## its-example.osm.pbf.3
    ## lines.txt
    ## openstreetmap_fr_zones.R
    ## out.txt
    ## test-gdal.md

``` bash
wget https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf

ogrinfo its-example.osm.pbf 
ogrinfo its-example.osm.pbf lines > lines.txt
head lines.txt
```

    ## --2021-04-11 09:32:38--  https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf
    ## Resolving github.com (github.com)... 140.82.121.3
    ## Connecting to github.com (github.com)|140.82.121.3|:443... connected.
    ## HTTP request sent, awaiting response... 302 Found
    ## Location: https://raw.githubusercontent.com/ropensci/osmextract/master/inst/its-example.osm.pbf [following]
    ## --2021-04-11 09:32:39--  https://raw.githubusercontent.com/ropensci/osmextract/master/inst/its-example.osm.pbf
    ## Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.109.133, 185.199.108.133, 185.199.111.133, ...
    ## Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.109.133|:443... connected.
    ## HTTP request sent, awaiting response... 200 OK
    ## Length: 40792 (40K) [application/octet-stream]
    ## Saving to: ‘its-example.osm.pbf.4’
    ## 
    ##      0K .......... .......... .......... .........            100% 3.04M=0.01s
    ## 
    ## 2021-04-11 09:32:39 (3.04 MB/s) - ‘its-example.osm.pbf.4’ saved [40792/40792]
    ## 
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 1: points (Point)
    ## 2: lines (Line String)
    ## 3: multilinestrings (Multi Line String)
    ## 4: multipolygons (Multi Polygon)
    ## 5: other_relations (Geometry Collection)
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: lines
    ## Geometry: Line String
    ## Feature Count: -1
    ## Extent: (-1.561196, 53.806303) - (-1.549845, 53.809293)
    ## Layer SRS WKT:
    ## GEOGCRS["WGS 84",
    ##     DATUM["World Geodetic System 1984",

``` bash
ogrinfo \
  -dialect sqlite -sql "SELECT highway, COUNT(*) from lines" \
  its-example.osm.pbf 
```

    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: SELECT
    ## Geometry: None
    ## Feature Count: 1
    ## Layer SRS WKT:
    ## (unknown)
    ## highway: String (0.0)
    ## COUNT(*): Integer (0.0)
    ## OGRFeature(SELECT):0
    ##   highway (String) = footway
    ##   COUNT(*) (Integer) = 189

``` bash
ogrinfo \
  -sql "SELECT DISTINCT highway from lines" \
  its-example.osm.pbf 
```

    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: lines
    ## Geometry: None
    ## Feature Count: 13
    ## Layer SRS WKT:
    ## (unknown)
    ## highway: String (0.0)
    ## OGRFeature(lines):0
    ##   highway (String) = footway
    ## 
    ## OGRFeature(lines):1
    ##   highway (String) = cycleway
    ## 
    ## OGRFeature(lines):2
    ##   highway (String) = service
    ## 
    ## OGRFeature(lines):3
    ##   highway (String) = residential
    ## 
    ## OGRFeature(lines):4
    ##   highway (String) = trunk
    ## 
    ## OGRFeature(lines):5
    ##   highway (String) = steps
    ## 
    ## OGRFeature(lines):6
    ##   highway (String) = unclassified
    ## 
    ## OGRFeature(lines):7
    ##   highway (String) = track
    ## 
    ## OGRFeature(lines):8
    ##   highway (String) = pedestrian
    ## 
    ## OGRFeature(lines):9
    ##   highway (String) = trunk_link
    ## 
    ## OGRFeature(lines):10
    ##   highway (String) = tertiary
    ## 
    ## OGRFeature(lines):11
    ##   highway (String) = (null)
    ## 
    ## OGRFeature(lines):12
    ##   highway (String) = corridor

``` bash
# fails
ogrinfo \
  -sql "SELECT DISTINCT other_tags from lines" \
  its-example.osm.pbf > test.txt # works
```

``` bash
# fails
ogrinfo \
  -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') from lines" \
  its-example.osm.pbf 
```

    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: lines
    ## Geometry: None
    ## Feature Count: 1
    ## Layer SRS WKT:
    ## (unknown)
    ## FIELD_1: String (0.0)
    ## OGRFeature(lines):0
    ##   FIELD_1 (String) =

``` bash
ogrinfo \
  -dialect sqlite -sql "SELECT highway, COUNT(*) from lines" \
  its-example.osm.pbf 
```

    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: SELECT
    ## Geometry: None
    ## Feature Count: 1
    ## Layer SRS WKT:
    ## (unknown)
    ## highway: String (0.0)
    ## COUNT(*): Integer (0.0)
    ## OGRFeature(SELECT):0
    ##   highway (String) = footway
    ##   COUNT(*) (Integer) = 189

``` bash
ogrinfo \
  -dialect sqlite -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle, hstore_get_value(other_tags, 'foot') AS foot FROM lines" \
  its-example.osm.pbf 
```

    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: SELECT
    ## Geometry: None
    ## Feature Count: 6
    ## Layer SRS WKT:
    ## (unknown)
    ## bicycle: String (0.0)
    ## foot: String (0.0)
    ## OGRFeature(SELECT):0
    ##   bicycle (String) = (null)
    ##   foot (String) = (null)
    ## 
    ## OGRFeature(SELECT):1
    ##   bicycle (String) = designated
    ##   foot (String) = designated
    ## 
    ## OGRFeature(SELECT):2
    ##   bicycle (String) = yes
    ##   foot (String) = (null)
    ## 
    ## OGRFeature(SELECT):3
    ##   bicycle (String) = (null)
    ##   foot (String) = yes
    ## 
    ## OGRFeature(SELECT):4
    ##   bicycle (String) = yes
    ##   foot (String) = yes
    ## 
    ## OGRFeature(SELECT):5
    ##   bicycle (String) = designated
    ##   foot (String) = yes

``` bash
ogrinfo \
  -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle, hstore_get_value(other_tags, 'foot') AS foot FROM lines" \
  its-example.osm.pbf > out.txt
```

    ## ERROR 6: SELECT DISTINCT not supported on multiple columns.

``` bash
ogrinfo \
  -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle FROM lines" \
  its-example.osm.pbf 
```

    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## ERROR 1: Invalid index : -1
    ## Had to open data source read-only.
    ## INFO: Open of `its-example.osm.pbf'
    ##       using driver `OSM' successful.
    ## 
    ## Layer name: lines
    ## Geometry: None
    ## Feature Count: 1
    ## Layer SRS WKT:
    ## (unknown)
    ## bicycle: String (0.0)
    ## OGRFeature(lines):0
    ##   bicycle (String) =

``` bash
  


# ogrinfo \
#   -sql "SELECT DISTINCT hstore_get_value(other_tags, 'bicycle') AS bicycle FROM lines" \
#   its-example.osm.pbf > out.txt
  
# cat out.txt

ogrinfo \
  -sql "SELECT hstore_get_value(other_tags, 'bicycle') AS bicycle FROM lines" \
  its-example.osm.pbf > out.txt
  
```
