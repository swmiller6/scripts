#!/bin/bash
# set path variables
importFile=$(ls -t /media/data/MAS90-backup/IMPORT/Amazon/DownloadDir/* | head -1)
aliasFile=/media/data/MAS90-backup/IMPORT/Amazon/aliasFile.txt
processedDirectory=/media/data/MAS90-backup/IMPORT/Amazon/ImportDir/
saveFile=$(ls -t /media/data/MAS90-backup/IMPORT/Amazon/SaveDir/*.txt | head -1)

# get rid of non text files
if [[ $importFile != *.txt ]]; then
        mv $importFile /media/data/MAS90-backup/IMPORT/Amazon/MiscDir/
fi

# wait before starting fix for removing first line download issue I think
#sleep 2

#if aliasFile has changed  make sure windows editor did not mess the file up for us
if [[ $aliasFile -nt $saveFile ]]; then
#dos2unix $aliasFile
#sleep 2

# remove whitespace and duplicates from amazon SKUs in alias conversion file
cat $aliasFile | awk 'BEGIN{FS=OFS="\t"}{gsub(/^[ \t]+/,"",$1);gsub(/[ \t]+$/,"",$1)}!seen[$0]++{print > "'"$aliasFile"'"}'
#sleep 2
fi

# check to make sure we are dealing with a txt file
if [[ ${importFile: -4} == ".txt" ]]; then
# totals up freight for duplicate lines
        awk 'BEGIN{FS=OFS="\t"}
        {
        a[$1]+= $14
        if (NR == 1)
            $14=$14
        else
            $14=a[$1]
        }{print > "importFile.tmp"}' $importFile && mv importFile.tmp $importFile
        wait;

# find mismatched item numbers and fix them
        awk 'BEGIN{FS=OFS="\t"}

        # populate array from alias file data
        NR==FNR{a[$1]=$0;next
        }

        {    
        
        # strip off the parentheses and leading:trailing whitespace in amazon file for accurate match to alias file
        gsub(/\ \(.*+$/,"",$8);gsub(/^[ \t]+/,"",$8);gsub(/[ \t]+$/,"",$8);

        # for matching amazon import field 8 in alias array split tab delimited fields into line array
        split(a[$8],line,"\t")

        # if match found change sku to lightbulbs sku and quantity to package quantity
        if ($8==line[1])
            {
                $8=line[2]
                $10=$10*line[3];
            }
        print > "'"$processedDirectory"'""/amazon--"strftime("%b-%d__%I-%M-%S")".txt"}' $aliasFile $importFile &
        wait;
        NOW=$(date +"%b-%d-%Y__%I-%M-%S")
        mv $importFile /media/data/MAS90-backup/IMPORT/Amazon/SaveDir/$NOW.txt
    else
        exit
fi
