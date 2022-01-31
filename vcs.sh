#!/usr/bin/env bash

command=$1
argument=$2

if [ "$command" == "init" ]
then
    if [ "$argument" != "" ]
    then
        if [ ! -f $argument ]
        then
            if [ ! -d $argument ]
            then
                mkdir $argument
                echo "Created directory $argument!"
            fi

            if [ ! -d $argument/.vcs ]
            then
                mkdir $argument/.vcs
                touch $argument/.vcs/.head
                echo 0 > $argument/.vcs/.head
                echo "Successfully initialized repository!"
            else
                echo "Directory already initialized!"
            fi
        else
            echo "Target is a file!"
        fi
    else
        echo "Usage: ./vcs.sh init [directory]"
    fi
elif [ "$command" == "commit" ]
then
    if [ "$argument" != "" ]
    then
        if [ -d $PWD/.vcs ]
        then
            echo "$(($commit + 1))" > $PWD/.vcs/.head
            commit=$(cat $PWD/.vcs/.head)
            mkdir $PWD/.vcs/$commit
            rsync -a . $PWD/.vcs/$commit --exclude .vcs
            touch $PWD/.vcs/$commit/.commit
            echo $USER > $PWD/.vcs/$commit/.commit
            echo $(date) >> $PWD/.vcs/$commit/.commit
            echo $argument >> $PWD/.vcs/$commit/.commit
            echo "Successfully created commit $commit!"
        else
            echo "No repository found in current directory!"
        fi
    else
        echo "Usage: ./vcs.sh commit [message]"
    fi
elif [ "$command" == "checkout" ]
then
    if [ "$argument" != "" ]
    then
        if [ -d $PWD/.vcs/$argument ]
        then
            for item in $PWD/*
            do
                if [ $item != ".vcs" ]
                then
                    rm -rf $item
                fi
            done

            rsync -a $PWD/.vcs/$argument/* . --exclude .commit
            echo "Successfully checked out commit $argument!"
        else
            echo "No commit found with matching id!"
        fi
    else
        echo "Usage: ./vcs.sh checkout [id]"
    fi
elif [ "$command" == "push" ]
then
    if [ -d $PWD/.vcs ]
    then
        foldername=$(basename "$PWD")
        zip -r $foldername.zip . > /dev/null 2>&1
        gdrive upload $foldername.zip > /dev/null 2>&1
        rm $foldername.zip
        echo "Successfully pushed project to Google Drive!"
    else
        echo "No repository found in current directory!"
    fi
elif [ "$command" == "log" ]
then
    echo "COMMITS"

    for commit in $PWD/.vcs/*
    do
        id=${commit#$PWD/.vcs/}
        echo
        echo "ID: $id"
        n=1

        while read line; do
            if [ $n == 1 ]
            then
                echo "username: $line"
            elif [ $n == 2 ]
            then
                echo "date: $line"
            elif [ $n == 3 ]
            then
                echo "message: $line"
            fi

            n=$((n+1))
        done < $commit/.commit
    done
else
    echo "Usage: ./vcs.sh [init|commit|checkout|push|log]"
fi