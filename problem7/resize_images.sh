#! /bin/bash

while read line
do
    filename=$line
    inpath="original_image"$filename
    echo "Coverting "$inpath
  
    outpath="resized_image"$filename
    echo "Saving 20% resized image to "$outpath
    #require ImageMagick support
    convert $inpath -resize 20\% $outpath
done < $1
