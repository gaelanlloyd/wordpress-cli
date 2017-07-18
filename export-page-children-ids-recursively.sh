#!/bin/bash
# Export the list of all child pages based on a parent page.

# Command arguments:

# 1. Post type (page, post, etc.)
# 2. Parent post ID
# 3. (optional) Multisite URL

postType=$1
id=$2
url=$3

# Set up storage
n=0
children=()
len_children=0
originalParent=$2

function getChildPosts {

    postType=$1
    id=$2
    url=$3

    cmd="wp post list --post_type=$postType --post_parent=$id --url=$url --format=csv --fields=ID"

    # Get first children and store in array
    results=( $($cmd) )

    # Count number of operations for periodic user progress report
    n=$((n+1))

    # Remove the "ID" header item in the array
    for child in "${results[@]}"
    do
        if [[ $child != "ID" ]]
        then

            # Store this legitimate child in the children array
            children+=($child)

            # Report progress every 10
            [[ $(( n % 10 )) == 0 ]] && echo -ne "...$n..."

            # Recursively fetch children of any posts returned for this post
            getChildPosts $postType $child $url

        fi
    done

}

echo -ne "Recursively retrieving child posts, please wait..."

getChildPosts $postType $id $url

len_children=${#children[@]}

echo ""
echo ""
echo "Parent post $originalParent has $len_children children:"

for child in "${children[@]}"
do
    echo "$child"
done
