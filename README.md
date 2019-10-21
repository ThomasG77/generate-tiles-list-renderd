# Recipes to render/manipulate tiles using renderd utilities

## Install dependencies

We supposed you have Perl installed, Python too, you also have wget, unzip and gdal installed. You have to run instructions within Ubuntu based system

```
sudo apt install python3 perl gdal-bin wget unzip
pip install --user supermercado
```

## Restrict tiles generated at lower level

We will use populated places to get list of tiles to avoid generating tiles where no one lives (less people interested, less infos so faster to render).
We can reuse this list of tiles to provide it to rendering utilities from renderd

```
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_urban_areas.zip
unzip ne_10m_urban_areas.zip
ogr2ogr -f GeoJSON ne_10m_urban_areas.geojson ne_10m_urban_areas.shp -lco RFC7946=YES
cat /dev/null >| /tmp/tiles_list.txt

cat ne_10m_urban_areas.geojson | supermercado burn 11 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 12 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 13 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
cat ne_10m_urban_areas.geojson | supermercado burn 14 | perl -pe 's/[\[,\]]//g' - >> /tmp/tiles_list.txt
wc -l tiles_list.txt
```

## Render tiles using render_list

The utility can run tiles pregeneration using levels, extent and list of tiles. We will render all tiles at higher level on the globe extent like below:

```
render_list -n 4 -z 0 -Z 10 -a
```

We will for "lower levels" (when zooming more), reuse tiles_list.txt and provide it to `render_list`.

```
cat /tmp/tiles_list.txt | render_list -n 4
```

## Expired tiles

If you make an update in the database, you want to refresh tiles images but you do not want to drop all your tiles as it can take a long time to generate all of them and can put an heavy load on your server. You may want to expire tiles images by zoom level(s) the existing tiles or provide custom logic e.g let's expire first this region then another one later.  The following consider you are using the default OpenStreetMap stack (mod_tile + renderd).
You may look at `man render_expired` to learn how to expire by zoom level. If you want more control on the exact tiles you expire, you will generate a list of xyz tiles, then filter then using your own logic before providing them to `render_expired` utility.

	# Create list of tiles xyz in meta files for a configuration
	python /home/thomasg/git/generate_tiles_list/tiles-utilities-renderd.py --map osmbright
	# Use the list, filter only level 10 and expire the tiles
    cat /tmp/list_tiles.txt | grep '^10/' | render_expired --num-threads=4 --map=osmbright --tile-dir=/var/lib/mod_tile

## Export meta tiles to XYZ

If you compile your own mod_tile (https://github.com/openstreetmap/mod_tile/), in your local copy, you can cd into `extra` directory and run `make`. Then, you are able to export meta file to standard xyz. It can be useful to host these tiles to a third-party server or push the images to mbtiles.

    # If you have some local cache in /var/lib/mod_tile/default
    mkdir /tmp/mytiles
    ./meta2tile -v /var/lib/mod_tile/default /tmp/mytiles
