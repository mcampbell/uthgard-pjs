#!/bin/bash

trap "echo Ending at `date --iso-8601=seconds` >> $HOME/logs/get-uthgard-home-page.sh.log" EXIT


set -eu
set -o pipefail

mkdir -p $HOME/logs
mkdir -p $HOME/uthgard/population

LOG=$HOME/logs/get-uthgard-home-page.sh.log
OUTPUT=$HOME/uthgard/population/$(/bin/date +%Y-%m-%d)-pj.log

echo Starting at $(date --iso-8601=seconds) >> $LOG

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

THISBIN="$(basename $0)"

cd $HERE

########################################
PJ="/home/mcampbell/phantomjs-2.0.0-20150528/bin/phantomjs"

# [2017-01-20T10:24:49-0500] <@[Uth]Infobot>  � Server Status � Online with 2753 clients and 4 queued clients  �
#   md = line.match(/.(\d\d\d\d)-(\d\d)-(\d\d).(\d\d):(\d\d).*Server Status . Online with (\d+) clients and (\d+) queued clients/)
NOW=$(date --iso-8601=seconds)

PLAYERS=$($PJ $HERE/get-uthgard-home-page.js | \
             grep Players: | \
             perl -ne 'print "$1\n" if m|(\d+)</td>|')

echo Got $PLAYERS players >> $LOG

echo "[${NOW}] Server Status � Online with ${PLAYERS} clients and 0 queued clients  �" >> $OUTPUT

# trap will get ending echo
