# get data
wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf

# too many features error
# ogrinfo -oo OGR_INTERLEAVED_READING=YES *pbf lines > x2

# no data
# ogrinfo -oo INTERLEAVED_READING=YES *pbf lines > x3

# with random layers
# ogrinfo -rl greater-london-latest.osm.pbf lines > x4
# ogrinfo -so x4
# head x4 -n 32

# use config file (works but has too many features error)
echo 'attributes=name,highway,waterway,aerialway,barrier,man_made,maxspeed' >> osmconf.ini
ogrinfo -oo CONFIG_FILE=osmconf.ini  greater-london-latest.osm.pbf lines > x5
head x5 -n 32

# convert format - works but no custom .ini
ogr2ogr -f gpkg -oo INTERLEAVED_READING=YES osm.gpkg greater-london-latest.osm.pbf
ogrinfo -so osm.gpkg lines

# convert format - works with custom osmconf2.ini file - with these contents:
# [lines]
# # common attributes
# osm_id=yes
# osm_version=no
# osm_timestamp=no
# osm_uid=no
# osm_user=no
# osm_changeset=no
#
# # keys to report as OGR fields
# attributes=name,highway,waterway,aerialway,barrier,man_made,maxspeed,oneway,building,surface,landuse,natural,start_date,wall,service,lanes,layer,tracktype,bridge,foot,bicycle,lit,railway,footway


ogr2ogr -f gpkg -oo CONFIG_FILE=osmconf2.ini  osm2.gpkg greater-london-latest.osm.pbf
ogrinfo -so osm2.gpkg lines # why does it have double the number of features?

ogr2ogr -f gpkg -oo CONFIG_FILE=osmconf2.ini -oo INTERLEAVED_READING=YES osm3.gpkg greater-london-latest.osm.pbf
ogrinfo -so osm2.gpkg lines # fails

ls -hal x*
ls -hal osm*
