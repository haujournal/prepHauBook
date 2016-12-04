#!/bin/bash

# Store arguments passed
FILE=$1

# Prompt for book info
read -p "What is the book's ID? (For example: the-book-title) " TITLEID
read -p "What is the book's title? " TITLE
read -p "Who is the book's author? " AUTHOR

# Create folder if it does not already exist
if [ -d $TITLEID ]; then
    rm -rf $TITLEID
fi
mkdir $TITLEID

# Uncompress file into folder
unzip -j -q $FILE -d $TITLEID
mkdir $TITLEID/images
mv $TITLEID/*.jpg $TITLEID/images/

# Remove link to stylesheet in HTML files and make images responsive
for file in $(ls $TITLEID/*.html)
do 
    sed -i 's:<link rel="stylesheet" type="text/css" href="template.css"/>::g' $file
    sed -i 's:<link href="template.css" type="text/css" rel="stylesheet" />::g' $file
    sed -i 's:<img src="images:<img class="img-responsive center-block" src="images:g' $file
done

# Remove template.css file
rm -f $TITLEID/template.css

# Construct JSON file
echo '{' > $TITLEID.json
echo '"titleID" : "'$TITLEID'",' >> $TITLEID.json
echo '"title" : "'$TITLE'",' >> $TITLEID.json
echo '"author" : "'$AUTHOR'",' >> $TITLEID.json
echo '"chapters" : [' >> $TITLEID.json
chapOrder=0
for chapter in $(ls $TITLEID/*.html | sort)
do
    fileRoot=$(echo $chapter | sed 's:\(.*\)/\(.*\).html:\2:')
    chapTitle=$(grep "<title>.*</title>" $chapter | sed \
    's:<title>\(.*\)</title>:\1:' | sed 's/.$//' | sed \
    's/&#x2019;/’/' | sed 's/&#x201[dD];/”/' | sed \
    's/&#x201[cC];/“/')

    # Check if it's the first file (i.e., front matter)
    if [ "$fileRoot" == "01_fm01" ]; then
        echo '    {' >> $TITLEID.json
        echo '    "chapTitle" : "Front Matter",' >> $TITLEID.json
        echo '    "order" : 0,' >> $TITLEID.json
        echo '    "file" : "'$fileRoot'"' >> $TITLEID.json
        echo '    },' >> $TITLEID.json
    elif [ "$fileRoot" == "01_fm00" ]; then
        echo '    {' >> $TITLEID.json
        echo '    "chapTitle" : "Front Matter",' >> $TITLEID.json
        echo '    "order" : 0,' >> $TITLEID.json
        echo '    "file" : "'$fileRoot'"' >> $TITLEID.json
        echo '    },' >> $TITLEID.json
    elif [ "$fileRoot" == "00_fm01" ]; then
        echo '    {' >> $TITLEID.json
        echo '    "chapTitle" : "Front Matter",' >> $TITLEID.json
        echo '    "order" : 0,' >> $TITLEID.json
        echo '    "file" : "'$fileRoot'"' >> $TITLEID.json
        echo '    },' >> $TITLEID.json
    elif [ "$fileRoot" == "00_fm00" ]; then
        echo '    {' >> $TITLEID.json
        echo '    "chapTitle" : "Front Matter",' >> $TITLEID.json
        echo '    "order" : 0,' >> $TITLEID.json
        echo '    "file" : "'$fileRoot'"' >> $TITLEID.json
        echo '    },' >> $TITLEID.json
    else
        echo '    {' >> $TITLEID.json
        echo '    "chapTitle" : "'$chapTitle'",' >> $TITLEID.json
        echo '    "order" : '$chapOrder',' >> $TITLEID.json
        echo '    "file" : "'$fileRoot'"' >> $TITLEID.json
        echo '    },' >> $TITLEID.json
    fi

    chapOrder=$((chapOrder+1))
done
echo ']' >> $TITLEID.json
echo '}' >> $TITLEID.json

# Construct TOC for Website
echo '<h5 id="toc" style="text-align: center;">Table of Contents</h5>' > $TITLEID.html
for chapter in $(ls $TITLEID/*.html | sort)
do
    fileRoot=$(echo $chapter | sed 's:\(.*\)/\(.*\).html:\2:')
    chapTitle=$(grep "<title>.*</title>" $chapter | sed \
    's:<title>\(.*\)</title>:\1:' | sed 's/.$//' | sed \
    's/&#x2019;/’/' | sed 's/&#x201[dD];/”/' | sed \
    's/&#x201[cC];/“/')

    echo '[row]' >> $TITLEID.html
    echo '[column md="4" offset_md="2" xclass="text-left"]' >> $TITLEID.html
    if [ "$fileRoot" == "01_fm01" ]; then
        echo 'Front Matter' >> $TITLEID.html
    elif [ "$fileRoot" == "01_fm00" ]; then
        echo 'Front Matter' >> $TITLEID.html
    elif [ "$fileRoot" == "00_fm01" ]; then
        echo 'Front Matter' >> $TITLEID.html
    elif [ "$fileRoot" == "00_fm00" ]; then
        echo 'Front Matter' >> $TITLEID.html
    else
        echo $chapTitle >> $TITLEID.html
    fi
    echo '[/column]' >> $TITLEID.html
    echo '[column md="4" xclass="text-right"]' >> $TITLEID.html
    echo '<a href="http://haubooks.org/viewbook/'$TITLEID'/'$fileRoot'">Full Text</a>' >> $TITLEID.html
    echo '[/column]' >> $TITLEID.html
    echo '[/row]' >> $TITLEID.html
done
