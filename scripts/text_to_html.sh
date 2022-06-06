#!/bin/bash

# $1: markdown file
filename=$1
basename=$(echo $1 | sed -e "s/.*\/\(.*\)\.md$/\1/g")

#######################################
# header
cat post_header > $basename.html
echo '' >> $basename.html

# parse contents
title=$(cat $filename | sed -e "/^##.*\$/d" | grep "#" | sed -e "s/^# \(.*\)\$/\1/g")
content_titles=($(grep "##" $filename | sed -e "s/^## \(.*\)\$/\1/g"))

# title
line_title=$(cat $filename | grep -n "# $title" | sed -e "s/:.*//g")
line_content_title_1=$(cat $filename | grep -n "## ${content_titles[0]}" | sed -e "s/:.*//g")
line_file_end=$(wc -l $filename | awk '{print $1}')
echo '<h2>'$title'</h2>' >> $basename.html
for i in `seq $(($line_title+1)) $(($line_content_title_1-1))`;do
    line=$(cat $filename | awk 'NR=='$i'{print $0}')
    if [ ! $line = "" ]; then
        echo '<p>'$line'</p>' >> $basename.html
    fi
done
echo '</div>' >> $basename.html
echo '' >> $basename.html

# content list
echo '<div class="mycontainer-list">' >> $basename.html
echo '<h2>Contents</h2>' >> $basename.html
echo '<ul>' >> $basename.html
count=1
for content in ${content_titles[@]};do
    echo '<li><a href="#'$count'">'$content'</a></li>' >> $basename.html
    count=$((++count))
done
echo '<ul>' >> $basename.html
echo '</div>' >> $basename.html
echo '' >> $basename.html

# contents
count=1
for content in ${content_titles[@]};do
    echo '<div class="mycontainer-contents" id="'$count'">' >> $basename.html
    echo '<h3>'$content'</h3>' >> $basename.html
    line_content_title=$(cat $filename | grep -n "## $content" | sed -e "s/:.*//g")
    for i in `seq $(($line_content_title+1)) $line_file_end`;do
        line=$(cat $filename | awk 'NR=='$i'{print $0}')
        if [ "${line:0:2}" = "##" ]; then
            break
        elif [ ! "$line" = "" ]; then
            echo '<p>'$line'</p>' >> $basename.html
        fi
    done
    count=$((++count))
    echo '</div>' >> $basename.html
    echo '' >> $basename.html
done

# footer
cat post_footer >> $basename.html

mv $basename.html /home/saori/su/htmls/posts/$basename.html

#######################################
# htmls/posts/index.html
file_latest_post=`ls -lt /home/saori/su/htmls/posts/2022*.html | head -n 1 | awk '{print $9}' | sed -e "s/.*\/\(.*\).html/\1/g"`
cur_line=`grep $file_latest_post /home/saori/su/htmls/posts/index.html`
title_latest_post=`echo $cur_line | sed -e "s/.*html\">\(.*\)<\/a><\/li>/\1/g"`
new_line=$(echo $cur_line | sed -e "s/[0-9]\{2\}\/[0-9]\{2\}/${basename:4:2}\/${basename:6:2}/g" -e "s/$file_latest_post/$basename/g" -e "s/$title_latest_post/$title/g")
new_line_mod=$(echo $new_line | sed -e 's/\//\\\//g')
sed -i "/$file_latest_post\.html/i $new_line_mod" /home/saori/su/htmls/posts/index.html

#######################################
# index.html
line_latest_news=$(cat /home/saori/su/index.html | grep -n News | sed -e "s/:.*//g")
cur_line=$(cat /home/saori/su/index.html | awk 'NR=='$((line_latest_news+2))'{print $0}')
cur_content=`echo $cur_line | sed -e "s/^.*<\/span>\(.*\)<\/li>.*$/\1/g"`
cur_path=`echo $cur_line | sed -e "s/.*ref=\"\(.*\)\".*/\1/g"`
content="<a href=\"htmls/posts/$basename.html\">$title</a>"
cur_content_mod=$(echo $cur_content | sed -e 's/\//\\\//g')
content_mod=$(echo $content | sed -e 's/\//\\\//g')
new_line=$(echo $cur_line | sed -e "s/[0-9]\{2\}\/[0-9]\{2\}\/[0-9]\{4\}/${basename:4:2}\/${basename:6:2}\/${basename:0:4}/g" -e "s/$cur_content_mod/$content_mod/g")
new_line_mod=$(echo $new_line | sed -e 's/\//\\\//g')
sed -i "$((line_latest_news+2))i $new_line_mod" /home/saori/su/index.html

#######################################
# index_jp.html
line_latest_news=$(cat /home/saori/su/index_jp.html | grep -n ニュース | sed -e "s/:.*//g")
cur_line=$(cat /home/saori/su/index_jp.html | awk 'NR=='$((line_latest_news+2))'{print $0}')
cur_content=`echo $cur_line | sed -e "s/^.*<\/span>\(.*\)<\/li>.*$/\1/g"`
cur_path=`echo $cur_line | sed -e "s/.*ref=\"\(.*\)\".*/\1/g"`
content="<a href=\"htmls/posts/$basename.html\">$title</a>"
cur_content_mod=$(echo $cur_content | sed -e 's/\//\\\//g')
content_mod=$(echo $content | sed -e 's/\//\\\//g')
new_line=$(echo $cur_line | sed -e "s/[0-9]\{2\}\/[0-9]\{2\}\/[0-9]\{4\}/${basename:4:2}\/${basename:6:2}\/${basename:0:4}/g" -e "s/$cur_content_mod/$content_mod/g")
new_line_mod=$(echo $new_line | sed -e 's/\//\\\//g')
sed -i "$((line_latest_news+2))i $new_line_mod" /home/saori/su/index_jp.html