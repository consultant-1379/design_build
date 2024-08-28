#!/bin/bash

function cloneRepo {
	repo=`cat $workspace/build.cfg | grep $module | grep $branch | awk -F " " '{print $6}'`
	echo $repo
	echo "Cloning $repo"
	git clone $repo
}

function tag {
	cd $workspace/eniq_events_ui
	git checkout $branch
#	git tag $productNumber-$rstate
	git tag TESTBLD1.1
}

function build {
	$workspace/eniq_events_ui/buildit.sh $workspace
}

function getProductNumber {
	productNumber=`cat $workspace/build.cfg | grep $module | grep $branch | awk -F " " '{print $3}'`
}

function setRstate {
	rstate=`cat $workspace/build.cfg | grep $module | grep $branch | awk -F " " '{print $4}'`
}


function initialise {
	module=$1
	branch=$2
	workspace=$3
	userId=$4
}


#------ Main Body of Script -------

if [ "$2" == "" ]; then
    echo usage: $0 \<module\> \<Branch\> \<workspace\> \<userId\>
    exit -1
fi    
   
initialise $@
#cloneRepo
setRstate
echo "The Rstate is:$rstate"
#build
#tag
