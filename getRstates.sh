#!/bin/bash

if [ "$2" == "" ]; then
	echo usage: $0 \<UI r-state Delivered into the Sprint\> \<Sprint\>
	exit -1
fi

version=$1
sprint=$2
pwd=`pwd`
uiProductNumber="CXC1730809"
uiRepoName="eniq_events_ui"
uiRepoHome="$pwd/../eniq_events_ui"
uiTag="$uiProductNumber-$version"
baselineTag="ENIQ_EVENTS_${sprint}_BASE"
configFile="$pwd/uiConfig.txt"
gerritServer="eselivm2v238l.lmera.ericsson.se"
portNumber=29418
tmpCloneDir="$pwd/tmpCloneDir"


function cloneRepos {

 	if [ -d "$tmpCloneDir" ]; then
    		echo "Removing old version of $tmpCloneDir"
    		rm -rf $tmpCloneDir
  	fi

  	mkdir $tmpCloneDir
  	cd $tmpCloneDir
	echo "Cloning Repo's to $tmpCloneDir"
  	while read p; do
    		artifactId=`echo $p | awk -F " " '{print $1}'`
    		repoName=`echo $p | awk -F " " '{print $2}'`
    		git clone ssh://$gerritServer:$portNumber/$artifactId/$repoName
  	done < $configFile

}


function applyTag {
	rstate=$4 #if the UI is passed in then the rstate will be included. Otherwise, for sub-modules the r-state needs to be taken from the delivered version of the pom.xml in the UI repo
	if [ "$rstate" == "" ]; then
		cd $tmpCloneDir/eniq_events_ui
		git checkout $uiTag
		rstate=`grep -A 2 ">$1<" pom.xml | grep -A 2 ">$2<" | grep "<version>" | sed s/\<version\>//g | sed s/\<.*//g | sed s/" "//g`
	fi
	cd $tmpCloneDir/$2
	tag=`git tag | grep $3 | grep $rstate`
	echo "running in $2 repo: git tag ${baselineTag} $tag"
	git tag ${baselineTag} $tag
	git push --tags

}


function cleanUp {
  cd $pwd
  rm -rf $tmpCloneDir
}




cloneRepos

while read c; do
  	artifactId=`echo $c | awk -F " " '{print $1}'`
   	repoName=`echo $c | awk -F " " '{print $2}'`
   	productNumber=`echo $c | awk -F " " '{print $3}'`
	if [ "$uiRepoName" == "$repoName" ]; then
		applyTag $artifactId $repoName $productNumber $version
	else
		applyTag $artifactId $repoName $productNumber
	fi
done < $configFile


cleanUp
