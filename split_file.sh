#!/bin/bash

###=============================================================================================###
### Split 1 txt file into several files by number of line/number of file 	                      ###
###	                                    								                                        ###
###	Notes			:					                                                                        ###
###	$1 = required file location 					                                                      ###
###	$2 = file name.txt                                                                          ###
###	$3 = split method (by number of file/line) <e.g: file>                                      ###
###	$4 = number of split file/line                                                              ###
###	$5 = header <header / headerless>                                                           ###
###	$6 = target dir <optional>                                                                  ###
###	to use this script :                                                                        ###
###  ./split_file.sh <file path> <filename> <split method> <chunks> <header> <target dir <opt>> ###
###=============================================================================================###

if [[ -z $1 || -z $2 || -z $3 || -z $4 || -z $5 ]]; then
  echo "ERROR!!! Missing necessary params." 
  exit 1
fi

path=$1
filename=$2
method=$3
chunks=$4
header=$5
tgt=$6
base_filename="${filename%.*}"

cd $path

if [ $header = header ]; then
    row_cnt=$(($(wc -l $filename | awk '{print $1}')-1))
else 
    row_cnt=$(wc -l $filename | awk '{print $1}')
fi
echo "Row count: $row_cnt"

# Find digits from total number of files created to tackle split behaviour explained on https://debbugs.gnu.org/cgi/bugreport.cgi?bug=20874
if [ $method = file ]; then
    digits=$(awk -F '[0-9]' '{print NF-1}' <<< $chunks)
else 
    digits=$(awk -F '[0-9]' '{print NF-1}' <<< $((row_cnt/chunks)))
fi
echo "Number of digits: $digits"

echo "Start split at: " $(date +”%Y-%m-%d_%H:%M:%S”)

if [ $header = header ]; then
    head -n 1 $filename > HEADER_$filename
    if [ $? -ne 0 ]; then
            exit 1
    fi 
    tail -n +2 $filename > CONTENT_$filename
    if [ $? -ne 0 ]; then
            exit 1
    fi
else 
    cat $filename > CONTENT_$filename
fi

if [ $method = line ]; then 
    split -a $digits -dl $chunks --verbose --additional-suffix=.txt CONTENT_$filename "${base_filename}split"
else
    split -a $digits -dn l/$chunks  --verbose --additional-suffix=.txt CONTENT_$filename "${base_filename}split"
fi 

if [ $? -ne 0 ]; then
    exit 1
fi

if [ $header = header ]; then
    for file in "${base_filename}split"*
    do
        cat HEADER_$filename > tmp_file
        if [ $? -ne 0 ]; then
            exit 1
        fi
        cat $file >> tmp_file
        if [ $? -ne 0 ]; then
            exit 1
        fi
        mv -f tmp_file $file
        if [ $? -ne 0 ]; then
            exit 1
        fi
    done
fi

echo "Done split at: " $(date +”%Y-%m-%d_%H:%M:%S”)
echo "Start zip at: " $(date +”%Y-%m-%d_%H:%M:%S”)

if [ -e $base_filename.zip ]; then
    rm $base_filename.zip
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

zip $base_filename.zip "${base_filename}split"*
if [ $? -ne 0 ]; then
    exit 1
fi

echo "Done zip at: " $(date +”%Y-%m-%d_%H:%M:%S”)

if [ -z "$tgt" ]; then
    echo "Data has been split & zipped successfully"
else
    echo "Start copy to $tgt at: " $(date +”%Y-%m-%d_%H:%M:%S”)
        cp $base_filename.zip $tgt
        if [ $? -ne 0 ]; then
            exit 1
        fi
    echo "Done copy to $tgt at: " $(date +”%Y-%m-%d_%H:%M:%S”)
    echo "Data has been split, zipped, & copied to NAS $tgt successfully"
fi

echo "Housekeeping temporary files ..."
if [ $header = header ]; then
    rm HEADER_$filename
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi
rm CONTENT_$filename
if [ $? -ne 0 ]; then
    exit 1
fi
rm ${base_filename}split*
if [ $? -ne 0 ]; then
    exit 1
fi
echo "Finished housekeeping temporary files"

exit 0
