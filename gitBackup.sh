#!/bin/sh

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 gitRepositoryURL gitBundleDestination gitBundleName" >&2
	exit 1
fi

GIT_REPOSITORY_URL=$1
GIT_BUNDLE_DESTINATION=$2
GIT_BUNDLE_NAME=$3
GIT_CLONE_DESTINATION=./backup

# erase destination if exists
rm -rf $GIT_CLONE_DESTINATION

git clone $GIT_REPOSITORY_URL $GIT_CLONE_DESTINATION
cd $GIT_CLONE_DESTINATION
git bundle create ./$GIT_BUNDLE_NAME --all
mv $GIT_BUNDLE_NAME $GIT_BUNDLE_DESTINATION
cd ..
rm -rf $GIT_CLONE_DESTINATION

