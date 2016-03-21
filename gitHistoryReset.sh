#!/bin/sh

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 gitRepositoryURL gitMasterBranch gitSecondaryBranch gitMasterCommitMessage gitSecondaryCommitMessage" >&2
	exit 1
fi

GIT_REPOSITORY_URL=$1
GIT_CLONE_DESTINATION=./tmp_git
GIT_MASTER_BRANCH=$2
GIT_SECONDARY_BRANCH=$3
GIT_MASTER_COMMIT_MESSAGE=$4
GIT_SECONDARY_COMMIT_MESSAGE=$5


# erase destination if exists
rm -rf $GIT_CLONE_DESTINATION
rm -f ./secondary_branch.tar.gz

git clone $GIT_REPOSITORY_URL $GIT_CLONE_DESTINATION
cd $GIT_CLONE_DESTINATION

# (optional) delete all tags
git tag -l | xargs -n 1 git push --delete origin && git tag | xargs git tag -d

# backup "release" branch
git checkout $GIT_SECONDARY_BRANCH
git archive HEAD | gzip > ../secondary_branch.tar.gz

# start from scratch on branch "master
git checkout $GIT_MASTER_BRANCH
rm -rf .git
git init && git add .
git commit -m "$GIT_MASTER_COMMIT_MESSAGE"

# overwrite repository
git remote add origin $GIT_REPOSITORY_URL
git push -u --force origin $GIT_MASTER_BRANCH

# restore "release" branch
git checkout -b $GIT_SECONDARY_BRANCH
git rm -rf .
tar xzvf ../secondary_branch.tar.gz | xargs -n 1 git add

git commit -m "$GIT_SECONDARY_COMMIT_MESSAGE"

git push origin $GIT_SECONDARY_BRANCH -f

# cleanup
rm -rf $GIT_CLONE_DESTINATION
rm -f ./secondary_branch.tar.gz
