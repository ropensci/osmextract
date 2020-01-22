wget http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf
ogrinfo -oo OGR_INTERLEAVED_READING=YES *pbf points > x1
ogrinfo -oo INTERLEAVED_READING=YES *pbf points > x1
