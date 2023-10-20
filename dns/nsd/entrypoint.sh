#!/bin/sh

TEMP_DIR='/tmp/zones'
ZONE_DIR='/etc/nsd/zones'

if [ -d "$TEMP_DIR" ]; then
  for file in $(ls "$TEMP_DIR" | grep .zone$); do
    if [ ! -f "$ZONE_DIR/$file" ]; then
      cp "$TEMP_DIR/$file" "$ZONE_DIR/$file"
    fi
  done

  rm -rf "$TEMP_DIR"
fi

exec $@
