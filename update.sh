#!/bin/bash

for release in 7.1 7.2 7.3 7.4; do
    version=$(curl -vo- "https://www.php.net/releases/?json&version=${release}" 2>curl.log | tee curl.out | jq -r '.version');
    if [ -z "${version}" ]; then
        cat curl.log
        cat curl.out
        exit 1
    else
        rm -f curl.log
        rm -f curl.out
    fi
    
    echo -n "${version} -- "
    tag=$(git tag -l "${version}")
    if [ -z "${tag}" ]; then
        # create tag
        git tag "${version}"
        echo "added"
    elif [ -z "$(git tag -l "${version}" --points-at HEAD)" ]; then
        # update tag
        git tag -d "${version}" > /dev/null
        git tag "${version}"
        echo "updated"
    else
        echo "already up-to-date"
    fi
done
git push --tags --force

