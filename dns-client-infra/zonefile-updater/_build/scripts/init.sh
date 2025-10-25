#!/bin/bash

set -e

mkdir -p $GIT_REPO_STORE

if [ ! -d $GIT_REPO_STORE/.git ]; then
    mkdir -p $GIT_REPO_STORE
    git clone --single-branch --branch $GIT_BRANCH $GIT_REPO_URL $GIT_REPO_STORE
fi

cd $GIT_REPO_STORE

while true; do
    git fetch origin || true
    git reset --hard origin/$GIT_BRANCH || true

    sleep $UPDATE_INTERVAL
    # Randomly sleep a moment to not always run at the exact same moment
    sleep $(shuf -i 1-20 -n 1)
done