# We supposed you have Perl installed,
# Python too, you also have wget, unzip and gdal installed
# You have to run the script using bash
sudo apt install python3 perl gdal-bin wget unzip
pip install --user supermercado

# We will use populated places to get list of tiles to avoid
# generating tiles where no one lives (less people interested,
# less infos so faster to render)
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip
unzip ne_10m_urban_areas.zip
ogr2ogr -f GeoJSON ne_10m_urban_areas.geojson ne_10m_urban_areas.shp -lco RFC7946=YES
cat /dev/null >| /tmp/tiles_list.txt

cat ne_10m_urban_areas.geojson | supermercado burn 11 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 12 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 13 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 14 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
wc -l tiles_list.txt

# Render all tiles at higher level on the globe extent
render_list -n 4 -z 0 -Z 10 -a
# Reuse tiles_list.txt to render when zooming more
cat /tmp/tiles_list.txt | render_list -n 4

