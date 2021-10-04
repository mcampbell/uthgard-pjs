#!/bin/bash

trap "echo Ending at `date --iso-8601=seconds`" EXIT

set -eu
set -o pipefail

################################################################################
# Misc setup
################################################################################

LOG_DIR=$HOME/logs
mkdir -p $LOG_DIR

OUTPUT_DIR=$HOME/uthgard/population
mkdir -p $OUTPUT_DIR

OUTPUT=$OUTPUT_DIR/$(/bin/date +%Y-%m-%d)-pj.log

echo Starting at $(/bin/date --iso-8601=seconds)

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(/bin/readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

THISBIN="$(/usr/bin/basename $0)"

function extract_ym_from_filename() {
    local name="$1"
    echo "$name" | perl -ne 'm|(\d{4}-\d{2})-\d{2}| && print("$1\n")'
}

cd "$OUTPUT_DIR"
for file in $(find . -mtime +3 -name '2*.log'); do
    ZIP=./archive-$(extract_ym_from_filename "$file").zip
    zip -rm -T "$ZIP" "$file" &
done

cd $HERE

################################################################################
# --Run phantomjs to scrape the home page for player info.--
# They made this not possible ~2021-09-30.  Use chromium instead.
################################################################################
NOW=$(/bin/date --iso-8601=seconds)

# PLAYERS=$(/usr/bin/docker run -i --rm mcampbell/uthgard-pjs | /bin/grep Players: | /usr/bin/perl -ne 'print "$1\n" if m|(\d+)</td>|')

PLAYERS=$(/usr/bin/chromium-browser --incognito --proxy-auto-detect --temp-profile --headless --dump-dom https://www2.uthgard.net 2>&1 | /bin/grep Players: | /usr/bin/perl -ne 'print "$1\n" if m|(\d+)</td>|')

echo Got $PLAYERS players

echo "[${NOW}] Server Status � Online with ${PLAYERS} clients and 0 queued clients  �" >> $OUTPUT

################################################################################
# update the sqlite3 database with player population data.  This is not terribly
# efficient, but it'll do.  It can recreate an entire day's worth of data in
# about a second, so... not too horrible.
################################################################################
YMD=$(date +%Y-%m-%d)
echo Updating data from ${OUTPUT_DIR}/${YMD}*.log
python3 ./update-population-db.py -d ./uthgard-population.db -l ${OUTPUT_DIR}/${YMD}*.log

# trap will get ending echo
