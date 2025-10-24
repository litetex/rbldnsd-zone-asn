#!/bin/bash

mkdir -p cached

CACHE_DIR=/workdir/cached

DWL_TMP_DIR=/workdir/tmp-dwl
rm -rf $DWL_TMP_DIR
mkdir -p $DWL_TMP_DIR

dos2unix dwl_src.txt
readarray -t DWL_SRC < dwl_src.txt

cached_file_names=()
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
for dwl_url in "${DWL_SRC[@]}"
do
    file_name=$(echo ${dwl_url##*/})
    cached_file_names+=($file_name)
    {
        echo "Downloading $dwl_url to $file_name"
        if wget --timeout=600 -qO - $dwl_url > $DWL_TMP_DIR/$file_name; then
            if [ -s $DWL_TMP_DIR/$file_name ]; then
                echo "Downloaded $dwl_url"
                mv $DWL_TMP_DIR/$file_name $CACHE_DIR/$file_name
                echo "Moved $file_name"
            else
                echo "[WARN] Empty payload received from $dwl_url - not copying"
            fi
        else
            echo "[WARN] Failed to download $dwl_url"
        fi
    } &
done
wait
echo "Finished downloading"
rm -rf $DWL_TMP_DIR

for cached_file in $CACHE_DIR/*
do
    file_name=$(basename $cached_file)
    if [[ ! " ${cached_file_names[*]} " =~ " ${file_name} " ]]; then
        echo "[WARN] Deleting $cached_file as it's not on the download list"
        rm -f $cached_file
    fi
done

rm -f asn.zone asn6.zone

echo "Running generation script (may take a moment)"
perl asn.pl --target $CACHE_DIR

echo "Generation done"

rm -rf out
mkdir -p out

for asnZoneFileName in asn asn6; do
    echo "Sorting and finalizing zone file: $asnZoneFileName"
    tail -n +3 $asnZoneFileName.zone | sort --parallel=4 > out/$asnZoneFileName.zone
done
