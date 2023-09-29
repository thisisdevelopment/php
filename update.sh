#!/bin/bash

releases=$(curl --retry 5 --retry-delay 10 -4 -vso- "https://www.php.net/releases/?json" 2>curl.log | tee curl.out | jq 'to_entries | .[] | select(if .value.supported_versions | length == 0 then .value.tags | index("security") else true end) | if .value.supported_versions | length == 0 then [.value.version[0:3]] else .value.supported_versions end' | jq -rs 'add | sort | reverse | join(" ")')
if [ -z "${releases}" ]; then
    cat curl.log
    cat curl.out
    exit 1
else
    rm -f curl.log
    rm -f curl.out
fi

for release in $releases; do
    version=$(curl --retry 5 --retry-delay 10 -4 -vso- "https://www.php.net/releases/?json&version=${release}" 2>curl.log | tee curl.out | jq -r '.version');
    if [ -z "${version}" ]; then
        cat curl.log
        cat curl.out
        exit 1
    else
        rm -f curl.log
        rm -f curl.out
    fi

    echo -n "${version} -- "
    docker manifest inspect php:$version 2>/dev/null 1>/dev/null || (c=$?; echo "no upstream docker image found"; exit $c) || continue
    
    tag=$(git tag -l "${version}")
    if [ -z "${tag}" ]; then
        # create tag
        git tag "${version}"
        git push origin "${version}:${version}"
        echo "added"
    elif [ -z "$(git tag -l "${version}" --points-at HEAD)" ]; then
        # update tag
        git tag -d "${version}" > /dev/null
        git push --delete origin "${version}"
        git tag "${version}"
        git push origin "${version}:${version}"
        echo "updated"
    else
        echo "already up-to-date"
    fi
done
