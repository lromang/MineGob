#!/bin/bash

for i in $(tail -n +2  ../data/MAT.csv | awk -F ',' '{print $13}')
do
    # Time prior URL verification.
    T="$(date)"

    # URL verification.
    urlstatus=$(timeout $1s curl -k -o /dev/null --silent --head --write-out '%{http_code}' "$i" )

    # Verification time.
    T=$(date-$T)

    # Check if timeout.
    if [ $(echo $urlstatus | wc -m) -eq 1 ]
    then
        urlstatus="time_out"
    fi

    # Print results.
    echo  "status: $urlstatus | execution time: $T | date: `date`"

    # Send results to file.
    echo -e  "$urlstatus \t $T \t `date`" >> urlstatus.csv
done
