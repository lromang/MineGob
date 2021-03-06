#!/bin/bash

for i in $(tail -n +2  ../data/all_urls.csv)
do
    # Time prior URL verification.
    T0=$(date +%s)

    # URL verification.
    urlstatus=$(timeout $1s curl -k -o /dev/null --silent --head --write-out '%{http_code}' "$i" )

    # Verification time.
    T1=$(date +%s)

    # Check if timeout.
    if [ $(echo $urlstatus | wc -m) -eq 1 ]
    then
        urlstatus="time_out"
    fi

    # Print results.
    echo  "status: $urlstatus | execution time: $(($T1 - $T0)) | date: `date`"

    # Send results to file.
    echo -e  "$urlstatus \t $T0 \t `date`" >> urlstatus.csv
done
