#!/bin/bash

SCRIPT="$0"
SCRIPTPATH=$(dirname "$SCRIPT" && pwd)

ARGS="$@"
BRANCH="master"

self_update_git() {

    cd $SCRIPTPATH && git fetch;

    # [ $(git diff --name-only origin/$BRANCH | grep $SCRIPT | wc -l | grep -Eo "\d+") -ne 0 ] && {
    [ $(cd $SCRIPTPATH && git diff --name-only origin/$BRANCH | wc -l | grep -Eo "\d+") -ne 0 ] && {
        
        if [[ $# -eq 0 ]]; then
            
            echo "Found a new version of me, updating myself...";

            cd $SCRIPTPATH && git pull --force
            cd $SCRIPTPATH && git checkout -f $BRANCH
            cd $SCRIPTPATH && git pull --force

            echo "Running the new version...";
            exec "$SCRIPT" "$@ --drss-force-merge";

        elif [[ ($# -eq 1) && ("$1" = "--drss-force-merge") ]]; then

            echo ">>> MERGE <<<";

            if [[ $(cd $SCRIPTPATH && git status | grep -o "nothing to commit") != "" ]]; then

                echo "Adding changes..."
                cd $SCRIPTPATH && git add .;
                cd $SCRIPTPATH && git commit -m "merge";

            fi

            echo "Running update..."
            cd $SCRIPTPATH && git pull && git push;

            echo "Running the new version after merge...";
            exec "$SCRIPT" "$@";

        else

            echo ">>> Problem!! <<<";

        fi

        # Now exit this old instance
        exit 1;

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

self_update_test(){
    echo "Call: self_update_test $@";
}

main() {
   echo "Running..."
}

self_update(){
    self_update_$@
}

case "$1" in 
    git|http|test) 
        self_update $ARGS
        main
    ;;
    * )
        echo "Invalid call!";
    ;;
esac
