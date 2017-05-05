#!/bin/bash

SCRIPTNAME="$0"
SCRIPT=$(readlink -n "$SCRIPTNAME")
SCRIPTPATH=$(dirname "$SCRIPT")
ARGS="$@"
BRANCH="master"

self_update() {
    cd $SCRIPTPATH
    git fetch

    [ $(git diff --name-only origin/$BRANCH | grep $SCRIPTNAME | wc -l) -ne 0 ] && {
        echo "Found a new version of me, updating myself..."
        git pull --force
        git checkout -f $BRANCH
        git pull --force
        echo "Running the new version..."
        exec "$SCRIPTNAME" "$ARGS"

        # Now exit this old instance
        exit 1
    }
    echo "Already the latest version."
}

self_update_http(){
    if [ $(wget --output-document=$SCRIPT.tmp $1/$SCRIPT) ]; then
        echo "error on wget on $SCRIPT update" 
        exit 1
    fi

    mv $SCRIPT.tmp $SCRIPT
}

main() {
   echo "Running..."
}

self_update $ARGS
main
