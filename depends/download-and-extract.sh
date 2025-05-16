#!/bin/sh
# Usage: ./download-and-extract.sh something https://example.com/something.tar.gz

archive=$1
url=$2

if [ ! -f $archive.tar.gz ]; then
    max_retries=3
    retry_count=0
    success=false
    
    echo "Downloading $url..."
    
    while [ $retry_count -lt $max_retries ] && [ "$success" = "false" ]; do
        if [ $retry_count -gt 0 ]; then
            sleep_time=$((5 * 2 ** (retry_count - 1)))  # Exponential backoff: 5s, 10s, 20s
            echo "Retry attempt $retry_count after $sleep_time seconds..."
            sleep $sleep_time
        fi
        
        wget --no-verbose -O $archive.tar.gz $url && success=true
        
        if [ "$success" = "false" ]; then
            echo "Download failed, HTTP error: $?"
            retry_count=$((retry_count + 1))
        fi
    done
    
    if [ "$success" = "false" ]; then
        echo "Failed to download $url after $max_retries attempts"
        exit 1
    fi
    
    echo "Successfully downloaded $url"
fi

rmdir $archive 2>/dev/null || true
tar -xvzf $archive.tar.gz
