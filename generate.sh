#!/bin/bash

mkdir -p cached

CACHE_DIR=/workdir/cached
SPLIT_CACHE_DIR=/workdir/cached-split

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

restoredLatestBView=false
if [ ! -f $CACHE_DIR/latest-bview.gz ]; then
    echo "Trying to restore latest-bview.gz from split cache"
    if [ -f $SPLIT_CACHE_DIR/latest-bview.zst.01 ]; then

        echo "Reassembling..."
        cat $SPLIT_CACHE_DIR/latest-bview.zst.* > /tmp/latest-bview.zst

        echo "Decompressing using zstd"
        zstd --decompress /tmp/latest-bview.zst
        rm -f /tmp/latest-bview.zst

        echo "Gzipping"
        pigz --fast < /tmp/latest-bview > $CACHE_DIR/latest-bview.gz
        rm -f /tmp/latest-bview

        restoredLatestBView=true
    fi
fi

for cached_file in $CACHE_DIR/*
do
    file_name=$(basename $cached_file)
    if [[ ! " ${cached_file_names[*]} " =~ " ${file_name} " ]]; then
        echo "[WARN] Deleting $cached_file as it's not on the download list"
        rm -f $cached_file
    fi
done

# rm -f asn.zone asn6.zone

# echo "Running generation script (may take a moment)"
# perl asn.pl --target $CACHE_DIR

# echo "Generation done"

# rm -rf out
# mkdir -p out

# for asnZoneFileName in asn asn6; do
#     echo "Sorting and finalizing zone file: $asnZoneFileName"
#     tail -n +3 $asnZoneFileName.zone | sort --parallel=4 > out/$asnZoneFileName.zone
# done

mkdir -p $SPLIT_CACHE_DIR
if [ -f $CACHE_DIR/latest-bview.gz ] && [ "$restoredLatestBView" = false ]; then
    echo "Saving latest-bview.gz to split cache"

    echo "Decompressing gzip"
    mkdir -p /tmp/latest-bview-work
    pigz -d < $CACHE_DIR/latest-bview.gz > /tmp/latest-bview-work/latest-bview

    echo "Recompressing with much more efficient zstd"
    zstd -T0 -19 /tmp/latest-bview-work/latest-bview
    rm -f /tmp/latest-bview-work/latest-bview

    echo "Splitting"
    split -b 50000000 -d /tmp/latest-bview-work/latest-bview.zst /tmp/latest-bview-work/latest-bview.zst.
    rm -f /tmp/latest-bview-work/latest-bview.zst

    echo "Moving into correct directory"
    rm -f $SPLIT_CACHE_DIR/latest-bview.zst*
    mv /tmp/latest-bview-work/latest-bview.zst.* $SPLIT_CACHE_DIR/
fi
